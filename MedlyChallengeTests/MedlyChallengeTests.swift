//
//  MedlyChallengeTests.swift
//  MedlyChallengeTests
//
//  Created by Alan Kantz on 11/20/20.
//

import XCTest
@testable import MedlyChallenge

class MedlyChallengeTests: XCTestCase {
    
    let timeout: TimeInterval = 10
    
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
    
    func test_ServiceCallToLocalJSONReturnsCountries() throws {
        // Given
        let service = CountryService.self
        let jsonFileURL = try XCTUnwrap(bundle.url(forResource: "TinyCountries", withExtension: "json"))
        let expectation = self.expectation(description: "The result will be set.")
        
        var result: Result<[Country], Error> = .failure(NSError(domain: "", code: .zero, userInfo: nil))
        
        // When
        service.getAll(from: jsonFileURL.absoluteString) { outcome in
            result = outcome
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout)
        let outcome = try result.get()
        XCTAssertEqual(outcome.count, 1)
    }
}
