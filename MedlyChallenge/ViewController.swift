//
//  ViewController.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

import UIKit

class ViewController: UITableViewController {
    
    private let countryService = CountryService.self
    private let cellClass = FlagTableViewCell.self
    
    private lazy var cellIdentifier = cellClass.description()
    
    private var countries = [Country]() {
        didSet { tableView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        requestCountryUpdates()
    }
    
    private func setUpTableView() {
        tableView.register(cellClass, forCellReuseIdentifier: cellIdentifier)
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

extension ViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let viewModel = countries[indexPath.row]
        if let cell = cell as? FlagTableViewCell {
            cell.textLabel?.text = viewModel.name
        }
        return cell
    }
}
