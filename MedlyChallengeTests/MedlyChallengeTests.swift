//
//  MedlyChallengeTests.swift
//  MedlyChallengeTests
//
//  Created by Alan Kantz on 11/20/20.
//

import XCTest
@testable import MedlyChallenge

class MedlyChallengeTests: XCTestCase {
    
    lazy var bundle = Bundle(for: type(of: self))
    
    func test_TinyCountriesJSONDecodes() throws {
        // Given
        let service = CountryService.self
        let jsonFileURL = try XCTUnwrap(bundle.url(forResource: "TinyCountries", withExtension: "json"))
        let data = try Data(contentsOf: jsonFileURL)
        
        // When
        let countries: [Country] = try service.decode(data: data, urlResponse: nil, error: nil)
        
        // Then
        XCTAssertEqual(countries.count, 1)
    }
}
