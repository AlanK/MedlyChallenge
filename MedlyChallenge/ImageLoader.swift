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
    
    private let cache = NSCache<NSString, UIImage>()
    
    private var allWaiters = [NSString: [(UIImage) -> Void]]()
    
    /// Load an image asynchronously and pass it to a handler.
    ///
    /// If loading fails, the handler will never be called.
    /// - Parameters:
    ///   - url: The location of the image.
    ///   - useImage: A function that will consume the requested image.
    ///   This will always be called on the main thread.
    func loadImage(atURL url: URL, useImage: @escaping (UIImage) -> Void) {
        let key = url.absoluteString as NSString
        if let image = cache.object(forKey: key) {
            useImage(image)
        } else {
            addWaiter(useImage, forKey: key)
            requestImage(atURL: url, forKey: key)
        }
    }
    
    private func addWaiter(_ waiter: @escaping (UIImage) -> Void, forKey key: NSString) {
        let existingWaiters = allWaiters[key] ?? []
        allWaiters[key] = existingWaiters + [waiter]
    }
    
    private func requestImage(atURL url: URL, forKey: NSString) {
        
    }
    
    private func loadedImage(_ image: UIImage, forKey key: NSString) {
        cache.setObject(image, forKey: key)
        DispatchQueue.main.async { [weak self] in
            guard
                let self = self,
                let waiters = self.allWaiters.removeValue(forKey: key)
            else { return }
            waiters.forEach { useImage in useImage(image) }
        }
    }
}
