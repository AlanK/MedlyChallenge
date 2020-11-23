//
//  Country.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/22/20.
//

/// A country fit for display.
struct Country {
    /// The name of the country.
    let name: String
    /// The name of the country capital, if applicable.
    let capital: String?
    /// The location of the country flag resource.
    let flagLocation: String
    
    /// Creates a new country instance from a network country instance.
    /// - Parameter rawCountry: The network country instance.
    init(_ rawCountry: NetworkCountry) {
        name = rawCountry.name
        capital = rawCountry.capital.isEmpty ? nil : rawCountry.capital
        flagLocation = "https://www.countryflags.io/\(rawCountry.flagCode)/flat/64.png"
    }
}
