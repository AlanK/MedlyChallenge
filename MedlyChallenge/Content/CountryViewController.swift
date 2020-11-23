//
//  CountryViewController.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

import UIKit

/// A view controller that displays a list of countries.
class CountryViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    private var cellIdentifier = Cell.self.description()
    private var imageLoads = [UIImageView: ImageLoader.Load]()
    
    private var separatorInset: UIEdgeInsets {
        var insets = UIEdgeInsets.zero
        insets.left = view.safeAreaInsets.left + 72
        return insets
    }
    
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
    
    override func viewSafeAreaInsetsDidChange() {
        tableView.separatorInset = separatorInset
    }
    
    // MARK: Private Methods
    
    private func setUpTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(Cell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.prefetchDataSource = self
        tableView.separatorInset = separatorInset
    }

    private func configureCell(_ cell: Cell, with viewModel: Country) {
        cell.accessibilityLabel = accessibilityText(for: viewModel)
        cell.countryLabel.text = viewModel.name
        cell.capitalLabel.text = viewModel.capital
        cell.capitalLabel.isHidden = viewModel.capital == nil
        
        let imageView = cell.flagImageView
        imageView.image = nil
        
        imageLoads
            .removeValue(forKey: imageView)
            .map(ImageLoader.shared.cancelLoad)
        
        guard let url = URL(string: viewModel.flagLocation) else { return }
        imageLoads[imageView] = ImageLoader.shared.loadImage(at: url) { [weak imageView] image in
            imageView?.image = image
        }
    }
    
    private func accessibilityText(for viewModel: Country) -> String {
        let extraInformation = viewModel.capital.map { capital in ", capital: \(capital)" } ?? ""
        return viewModel.name + extraInformation
    }
    
    // MARK: - Private Nested Types
    
    private typealias Cell = CountryTableViewCell
}

// MARK: - Table View Data Source & Delegate

extension CountryViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let viewModel = countries[indexPath.row]
        if let cell = cell as? Cell {
            configureCell(cell, with: viewModel)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = countries[indexPath.row]
        show(ViewController(viewModel), sender: nil)
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
            .map(\.element.flagLocation)
            .compactMap(URL.init(string:))
            .forEach(ImageLoader.shared.preloadImage)
    }
}
