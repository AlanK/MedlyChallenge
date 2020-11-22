//
//  ImageLoader.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/22/20.
//

import UIKit

class ImageLoader {
    
    private let cache = NSCache<NSString, UIImage>()
    
    private var allWaiters = [NSString: [(UIImage) -> Void]]()
    
    func loadImage(atLocation location: String, useImage: @escaping (UIImage) -> Void) {
        let key = location as NSString
        if let image = cache.object(forKey: key) {
            useImage(image)
        } else {
            addWaiter(useImage, forKey: key)
            requestImage(forKey: key)
        }
    }
    
    private func addWaiter(_ waiter: @escaping (UIImage) -> Void, forKey key: NSString) {
        let existingWaiters = allWaiters[key] ?? []
        allWaiters[key] = existingWaiters + [waiter]
    }
    
    private func requestImage(forKey key: NSString) {
        
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
