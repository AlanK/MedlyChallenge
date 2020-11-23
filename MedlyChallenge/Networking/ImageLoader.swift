//
//  ImageLoader.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/22/20.
//

import UIKit

/// Loads remote images asynchonously.
///
/// Only call an image loader from the main thread.
class ImageLoader {
    
    // MARK: - Private Properties
    
    private let cache = NSCache<Key, UIImage>()
    
    private var allWaiters = [Key: [UUID: ImageUser]]()
    private var keys = [UUID: Key]()
    
    // MARK: - Initializers
    
    /// The image loader singleton.
    ///
    /// Please—only call me from the main thread!
    static let shared: ImageLoader = ImageLoader()
    
    private init() { }
    
    // MARK: - Methods
    
    /// Load an image asynchronously and pass it to a handler.
    ///
    /// If loading fails, the handler will never be called.
    /// - Parameters:
    ///   - url: The location of the image.
    ///   - useImage: A function that will consume the requested image.
    ///   This will always be called on the main thread.
    /// - Returns: An opaque token representing an in-progress load.
    /// This is `nil` if the request waas satisfied immediately.
    /// See `cancelLoad(_:)` for more information.
    func loadImage(atURL url: URL, useImage: @escaping ImageUser) -> Load? {
        let key = url.absoluteString as Key
        if let image = cache.object(forKey: key) {
            useImage(image)
            return nil
        } else {
            let id = UUID()
            if addWaiter(useImage, withID: id, forKey: key) {
                requestImage(atURL: url, forKey: key)
            }
            return Load(id: id)
        }
    }
    
    /// Request an image that may be needed soon.
    ///
    /// Call this method to "warm up" an image you don't need now, but expect to need soon.
    /// - Parameter url: The location of the image.
    func preloadImage(atURL url: URL) {
        _ = loadImage(atURL: url) { _ in }
    }
    
    /// Cancel the loading of an image represented by a `Load` token.
    ///
    /// If a request to load an image cannot be satisfied immediately, the caller receives a `Load` token.
    /// If the caller later decides to cancel their image loading request, they can call `cancelLoad(_:)`
    /// with the `Load` token.
    ///
    /// Note that this does not affect network activity, it merely stops the retreived image from being
    /// passed back to the caller.
    /// - Parameter load: An opaque token representing an in-progress load.
    func cancelLoad(_ load: Load) {
        let id = load.id
        guard let key = keys.removeValue(forKey: id) else { return }
        allWaiters[key]?.removeValue(forKey: id)
    }
    
    // MARK: Private Methods
    
    private func addWaiter(_ waiter: @escaping ImageUser, withID id: UUID, forKey key: Key) -> Bool {
        let existingWaiters = allWaiters[key] ?? [:]
        let newWaiters = existingWaiters.merging([id: waiter]) { _, new in new }
        allWaiters[key] = newWaiters
        return existingWaiters.isEmpty
    }
    
    private func requestImage(atURL url: URL, forKey key: Key) {
        ImageService.getImage(fromURL: url) { [weak self] result in
            guard let self = self else { return }
            let image = try? result.get()
            self.didGetImage(image, forKey: key)
        }
    }
    
    /// This is the only method you're allowed to call off the main thread.
    private func didGetImage(_ image: UIImage?, forKey key: Key) {
        image.map { image in cache.setObject(image, forKey: key) } // The cache is thread-safe
        DispatchQueue.main.async { [weak self] in self?.fulfillWaiters(with: image, forKey: key) }
    }
    
    private func fulfillWaiters(with image: UIImage?, forKey key: Key) {
        guard let waiters = allWaiters.removeValue(forKey: key) else { return }
        for (loadID, useImage) in waiters {
            keys[loadID] = nil
            image.map(useImage)
        }
    }
    
    // MARK: - Nested Types
    
    typealias ImageUser = (UIImage) -> Void
    
    /// A load is an opaque token representing an in-progress image loading action.
    ///
    /// To cancel a load, pass the load object to the `cancelLoad(_:)`
    /// method of the image loader that produced it.
    struct Load {
        
        fileprivate let id: UUID
    }
    
    // MARK: Private Nested Types
    
    private typealias Key = NSString
}
