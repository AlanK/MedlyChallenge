//
//  CountryViewController.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

import UIKit

/// A view controller that displays a list of countries.
class CountryViewController: UITableViewController {
    
    // MARK: Private Properties
    
    private let countryService = CountryService.self
    private let cellClass = Cell.self
    
    private var cellIdentifier = Cell.self.description()
    private var imageLoads = [UIImageView: ImageLoader.Load]()
    
    private let countries: [Country]
    
    // MARK: - Initializers
    
    /// Creates a new view controller displaying the provided list of countries
    /// - Parameter countries: The countries to display.
    init(countries: [Country]) {
        self.countries = countries
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    // MARK: Private Methods
    
    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(cellClass, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: .zero, left: 72, bottom: .zero, right: .zero)
        tableView.allowsSelection = false
    }

    private func configureCell(
        _ cell: Cell,
        forRowAt indexPath: IndexPath,
        with viewModel: Country
    ) {
        
        cell.countryLabel.text = viewModel.name
        cell.capitalLabel.text = viewModel.capital
        cell.capitalLabel.isHidden = viewModel.capital.isEmpty
        
        let imageView = cell.flagImageView
        imageView.image = nil
        
        imageLoads
            .removeValue(forKey: imageView)
            .map(ImageLoader.shared.cancelLoad)
        
        guard let url = url(forCountryCode: viewModel.flagCode) else { return }
        imageLoads[imageView] = ImageLoader.shared.loadImage(atURL: url) { [weak imageView] image in
            imageView?.image = image
        }
    }
    
    private func url(forCountryCode code: String) -> URL? {
        URL(string: "https://www.countryflags.io/\(code)/flat/64.png")
    }
    
    // MARK: - Private Nested Types
    
    private typealias Cell = CountryTableViewCell
}

// MARK: - Table View Data Source

extension CountryViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let viewModel = countries[indexPath.row]
        if let cell = cell as? Cell {
            configureCell(cell, forRowAt: indexPath, with: viewModel)
        }
        return cell
    }
}

// MARK: - Table View Data Source Prefetching

extension CountryViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let rows = Set(indexPaths.map(\.row))
        countries
            .lazy
            .enumerated()
            .filter { element in rows.contains(element.offset) }
            .map(\.element)
            .map(\.flagCode)
            .compactMap(url)
            .forEach(ImageLoader.shared.preloadImage)
    }
}
