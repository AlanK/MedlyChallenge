//
//  Service.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

import Foundation

/// Helper functions for making network calls.
///
/// Typical use:
/// ```swift
/// enum SomeService: ServiceProtocol {
///     static func getThing(_ completionHandler: @escaping (Result<Bool, Error>) -> Void) {
///         requestLocation("some.url/string", completionHandler: completionHandler)
///     }
/// }
/// ```
/// Prefer `requestURL(_:completionHandler:)` over `requestLocation(_:completionHandler:)`
/// if a URL is available.
protocol Service { }

extension Service {
    
    /// Request a remote resource by string.
    ///
    /// The resource must be decodable.
    /// - Parameters:
    ///   - location: The string representation of a URL.
    ///   - completionHandler: A function to consume the resulting instance (or error).
    static func requestLocation<Output: Decodable>(
        _ location: String,
        completionHandler: @escaping (Result<Output, Error>) -> Void
    ) {
        guard let url = URL(string: location) else {
            return completionHandler(.failure(RequestError.couldNotCreateURL(input: location)))
        }
        requestURL(url, completionHandler: completionHandler)
    }
    
    /// Request a remote resource by URL.
    ///
    /// The resource must be decodable.
    /// - Parameters:
    ///   - url: The URL of the resource.
    ///   - completionHandler: A function to consume the resulting instance (or error).
    static func requestURL<Output: Decodable>(
        _ url: URL,
        completionHandler: @escaping (Result<Output, Error>) -> Void
    ) {
        requestURL(url, decoder: decode, completionHandler: completionHandler)
    }
    
    /// Request a remote resource by URL with a custom decoding function.
    /// - Parameters:
    ///   - url: The URL of the resource.
    ///   - decoder: The function to use to decode the response.
    ///   - completionHandler: A function to consume the output of the decoder.
    static func requestURL<Output>(
        _ url: URL,
        decoder: @escaping (Data?, URLResponse?, Error?) throws -> Output,
        completionHandler: @escaping (Result<Output, Error>) -> Void
    ) {
        URLSession.shared
            .dataTask(with: url, completionHandler: feed(completionHandler, withOutputOf: decoder))
            .resume()
    }
    
    /// An adapter for passing a typical network call completion handler directly to a data task initializer.
    /// - Parameter completionHandler: A completion handler in the form of `(Result<DecodedOutput, Error>) -> Void`.
    /// - Returns: A function that can be passed to a data task initializer.
    static func finish<Output: Decodable>(
        with completionHandler: @escaping (Result<Output, Error>) -> Void
    ) -> (Data?, URLResponse?, Error?) -> Void {
        
        feed(completionHandler, withOutputOf: decode)
    }
    
    /// An adapter for connecting a typical network call completion handler to a decoding function.
    ///
    /// If the thing being decoded is `Decodable`, take a look at `finish(with:)`.
    /// - Parameters:
    ///   - completion: A completion handler in the form of `(Result<Output, Error>) -> Void`.
    ///   - responseHandler: A response handler that decodes a network response into a usable value.
    /// - Returns: A function that can be passed to a data task initializer.
    static func feed<Output>(
        _ completion: @escaping (Result<Output, Error>) -> Void,
        withOutputOf responseHandler: @escaping (Data?, URLResponse?, Error?) throws -> Output
    ) -> (Data?, URLResponse?, Error?) -> Void {
        
        { (data, urlResponse, error) in
            let result = Result { try responseHandler(data, urlResponse, error) }
            completion(result)
        }
    }
    
    /// Attempts to decode a value from a network response.
    /// - Parameters:
    ///   - data: An optional data object. If this is `nil`, the function will throw.
    ///   - urlResponse: An optional URL response object.
    ///   - error: An optional error. If this is not `nil`, it will be thrown.
    /// - Throws: The provided error, or a `ResponseError`.
    /// - Returns: A decoded value.
    static func decode<Output: Decodable>(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> Output {
        if let error = error { throw error }
        guard let data = data else { throw ResponseError.dataWasNil }
        return try JSONDecoder().decode(Output.self, from: data)
    }
}

/// An error encountered while making a network request.
enum RequestError: LocalizedError {
    case couldNotCreateURL(input: String)
    
    var errorDescription: String? {
        switch self {
        case let .couldNotCreateURL(input): return "Could not create URL from input string \(input)"
        }
    }
}

/// An error encountered while handling the response to a network request.
enum ResponseError: LocalizedError {
    case dataWasNil
    
    var errorDescription: String? {
        switch self {
        case .dataWasNil: return "The data returned by the call was unexpectedly nil."
        }
    }
}
