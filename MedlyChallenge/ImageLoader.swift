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
            if addWaiter(useImage, withID: id, forKey: key) {
                requestImage(atURL: url, forKey: key)
            }
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
    
    private func addWaiter(
        _ waiter: @escaping ImageUser,
        withID id: UUID, forKey key: NSString
    ) -> Bool {
        
        let existingWaiters = allWaiters[key] ?? [:]
        let newWaiters = existingWaiters.merging([id: waiter]) { _, new in new }
        allWaiters[key] = newWaiters
        return existingWaiters.isEmpty
    }
    
    private func requestImage(atURL url: URL, forKey key: NSString) {
        ImageService.requestURL(url, decoder: ImageService.decodeImage) { [weak self] result in
            guard let self = self else { return }
            let image = try? result.get()
            self.didGetImage(image, forKey: key)
        }
    }
    
    private func didGetImage(_ image: UIImage?, forKey key: NSString) {
        image.map { image in cache.setObject(image, forKey: key) }
        DispatchQueue.main.async { [weak self] in self?.fulfillWaiters(with: image, forKey: key) }
    }
    
    private func fulfillWaiters(with image: UIImage?, forKey key: NSString) {
        guard let waiters = allWaiters.removeValue(forKey: key) else { return }
        for (loadID, useImage) in waiters {
            loadIDs[loadID] = nil
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
    
    private enum ImageService: Service {
        
        static func decodeImage(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> UIImage {
            if let error = error { throw error }
            guard let data = data else { throw ResponseError.dataWasNil }
            guard let image = UIImage(data: data) else { throw LoadingError.dataDidNotContainImage(data) }
            return image
        }
    }
    
    private enum LoadingError: LocalizedError {
        case dataDidNotContainImage(Data)
        
        var errorDescription: String? {
            switch self {
            case let .dataDidNotContainImage(data): return "Did not find image in data: \(data)"
            }
        }
    }
}
