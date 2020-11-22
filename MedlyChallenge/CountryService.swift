//
//  CountryService.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

import Foundation

enum CountryService: Service {
    
    /// Get a list of countries asynchronously.
    /// - Parameter location: Text representing the location of the country list.
    /// - Parameter completionHandler: The function to call with the result of getting the list of countries, either the list or an error.
    static func getAll(fromURL url: URL? = nil, _ completionHandler: @escaping (Result<[Country], Error>) -> Void) {
        let urlText = "https://restcountries.eu/rest/v2/all?fields=name;alpha2Code;capital"
        guard let requestURL = url ?? URL(string: urlText) else {
            return completionHandler(.failure(RequestError.couldNotCreateURL(input: urlText)))
        }
        URLSession.shared
            .dataTask(with: requestURL, completionHandler: finish(with: completionHandler))
            .resume()
    }
}
