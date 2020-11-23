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
    static func getAll(from url: URL? = nil, _ completionHandler: @escaping (Result<[NetworkCountry], Error>) -> Void) {
        if let url = url {
            requestURL(url, completionHandler: completionHandler)
        } else {
            requestLocation("https://restcountries.eu/rest/v2/all?fields=name;alpha2Code;capital",
                            completionHandler: completionHandler)
        }
    }
}
