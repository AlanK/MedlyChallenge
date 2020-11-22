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
    
    private let cache = NSCache<NSString, UIImage>()
    
    private var allWaiters = [NSString: [UUID: ImageUser]]()
    private var loadIDs = [UUID: NSString]()
    
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
        let key = url.absoluteString as NSString
        if let image = cache.object(forKey: key) {
            useImage(image)
            return nil
        } else {
            let id = UUID()
            addWaiter(useImage, withID: id, forKey: key)
            requestImage(atURL: url, forKey: key)
            return Load(id: id)
        }
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
        guard let key = loadIDs.removeValue(forKey: id) else { return }
        allWaiters[key]?.removeValue(forKey: id)
    }
    
    // MARK: Private Methods
    
    private func addWaiter(_ waiter: @escaping ImageUser, withID id: UUID, forKey key: NSString) {
        let existingWaiters = allWaiters[key] ?? [:]
        allWaiters[key] = existingWaiters.merging([id: waiter]) { _, new in new }
    }
    
    private func requestImage(atURL url: URL, forKey: NSString) {
        
    }
    
    private func didGetImage(_ image: UIImage, forKey key: NSString) {
        cache.setObject(image, forKey: key)
        DispatchQueue.main.async { [weak self] in self?.fulfillWaiters(with: image, forKey: key) }
    }
    
    private func fulfillWaiters(with image: UIImage, forKey key: NSString) {
        guard let waiters = allWaiters.removeValue(forKey: key) else { return }
        for (loadID, useImage) in waiters {
            loadIDs[loadID] = nil
            useImage(image)
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
}
