//
//  CountryService.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

import Foundation

enum CountryService: Service {
    
    /// Get a list of countries asynchronously.
    /// - Parameter location: Text representing the location where the list of countries is located.
    /// - Parameter completionHandler: The function to call with the result of getting the list of countries, either the list or an error.
    static func getAll(from location: String = "https://restcountries.eu/rest/v2/all",
                       _ completionHandler: @escaping (Result<[Country], Error>) -> Void) {
        
        guard let url = URL(string: location) else {
            return completionHandler(.failure(RequestError.couldNotCreateURL(input: location)))
        }
        URLSession.shared
            .dataTask(with: url, completionHandler: finish(with: completionHandler))
            .resume()
    }
}
