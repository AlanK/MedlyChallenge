//
//  ImageService.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/22/20.
//

import UIKit

/// A service for requesting remote images.
enum ImageService: Service {
    
    /// Requests a remote image and passes the result to a completion handler.
    ///
    /// You probably don't want to use this directly. Instead, take a look at `ImageLoader`.
    /// - Parameters:
    ///   - url: The URL of the remote image.
    ///   - completionHandler: A function to consume the resulting image (or error).
    static func getImage(from url: URL, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        requestURL(url, decoder: decodeImageData, completionHandler: completionHandler)
    }
    
    private static func decodeImageData(_ data: Data?, urlResponse: URLResponse?, error: Error?) throws -> UIImage {
        if let error = error { throw error }
        guard let data = data else { throw ResponseError.dataWasNil }
        guard let image = UIImage(data: data) else { throw LoadingError.dataDidNotContainImage(data) }
        return image
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
