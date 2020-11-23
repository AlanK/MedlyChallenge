//
//  NetworkCountry.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

/// A country with a name, flag code, and capital.
struct NetworkCountry: Decodable {
    /// The name of the country.
    let name: String
    /// The `alpha2Code` for the country, used to identify the country flag.
    let flagCode: String
    /// The capital of the country.
    let capital: String
    
    private enum CodingKeys: String, CodingKey {
        case name
        case flagCode = "alpha2Code"
        case capital
    }
}
