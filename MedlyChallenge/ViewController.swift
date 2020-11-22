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
    
    private var imageLoads = [UIImageView: ImageLoader.Load]()
    
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
    
    private func configureCell(_ cell: FlagTableViewCell, withViewModel viewModel: Country) {
        cell.textLabel?.text = viewModel.name
        cell.detailTextLabel?.text = viewModel.capital
        
        guard let imageView = cell.imageView else { return }
        imageLoads[imageView].map(ImageLoader.shared.cancelLoad)
        imageView.image = nil
        guard let url = URL(string: "https://www.countryflags.io/\(viewModel.flagCode)/flat/64.png") else { return }
        imageLoads[imageView] = ImageLoader.shared.loadImage(atURL: url) { [weak imageView] image in
            imageView?.image = image
        }
    }
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let viewModel = countries[indexPath.row]
        if let cell = cell as? FlagTableViewCell {
            cell.textLabel?.text = viewModel.name
        }
        return cell
    }
}
