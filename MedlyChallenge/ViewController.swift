//
//  ViewController.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

import UIKit

class ViewController: UIViewController {
    
    private let countryService = CountryService.self
    
    private var countries = [Country]()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCountryUpdates()
    }

    private func requestCountryUpdates() {
        countryService.getAll { [weak self] result in
            guard
                let self = self,
                let countries = try? result.get()
            else { return }
            DispatchQueue.main.async { self.countries = countries }
        }
    }
}

