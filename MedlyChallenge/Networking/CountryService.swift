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
    /// - Parameter url: An optional URL to substitute.
    /// - Parameter filter: A filter!
    static func getAll(
        from url: URL? = nil,
        with filter: [String]? = ["name", "alpha2Code", "capital", "population", "timezones"],
        _ completionHandler: @escaping (Result<[NetworkCountry], Error>) -> Void
    ) {
        
        if let url = url {
            requestURL(url, completionHandler: completionHandler)
        } else {
            let baseFilter = "?fields="
            let filterList = filter.map { filter in baseFilter + filter.joined(separator: ";") } ?? ""
            requestLocation("https://restcountries.eu/rest/v2/all\(filterList)",
                            completionHandler: completionHandler)
        }
    }
}
