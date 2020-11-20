//
//  Service.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

import Foundation

enum Service {
    
    /// Get a list of countries asynchronously.
    /// - Parameter completionHandler: The function to call with the result of getting the list of countries, either the list or an error.
    static func getCountries(_ completionHandler: @escaping (Result<[Country], Error>) -> Void) {
        let resourceLocation = "https://restcountries.eu/rest/v2/all"
        guard
            let url = URL(string: resourceLocation)
        else { return completionHandler(.failure(RequestError.couldNotCreateURL(input: resourceLocation))) }
        URLSession.shared.dataTask(with: url) { data, _, error in
            completionHandler(
                Result {
                    if let error = error { throw error }
                    guard let data = data else { throw ResponseError.dataWasNil }
                    return try JSONDecoder().decode([Country].self, from: data)
                }
            )
        }
    }
    
    enum RequestError: LocalizedError {
        case couldNotCreateURL(input: String)
        
        var errorDescription: String? {
            switch self {
            case let .couldNotCreateURL(input): return "Could not create URL from input string \(input)"
            }
        }
    }
    
    enum ResponseError: LocalizedError {
        case dataWasNil
        
        var errorDescription: String? {
            switch self {
            case .dataWasNil: return "The data returned by the call was unexpectedly nil."
            }
        }
    }
}
