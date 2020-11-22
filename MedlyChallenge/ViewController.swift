//
//  ViewController.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

import UIKit

class ViewController: UITableViewController {
    
    override var navigationItem: UINavigationItem { nav }
    
    private let countryService = CountryService.self
    private let cellClass = FlagTableViewCell.self
    
    private lazy var cellIdentifier = cellClass.description()
    
    private lazy var nav: UINavigationItem = {
        let nav = UINavigationItem()
        nav.title = "Countries"
        nav.largeTitleDisplayMode = .always
        return nav
    }()
    
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
        tableView.allowsSelection = false
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
    
    private func configureCell(
        _ cell: FlagTableViewCell,
        forRowAt indexPath: IndexPath,
        with viewModel: Country
    ) {
        
        cell.textLabel?.text = viewModel.name
        cell.detailTextLabel?.text = viewModel.capital
        cell.imageView?.contentMode = .scaleAspectFit
        
        guard let imageView = cell.imageView else { return }
        imageView.image = nil
        
        imageLoads
            .removeValue(forKey: imageView)
            .map(ImageLoader.shared.cancelLoad)
        
        guard let url = URL(string: "https://www.countryflags.io/\(viewModel.flagCode)/flat/64.png") else { return }
        imageLoads[imageView] = ImageLoader.shared.loadImage(atURL: url) { [weak self, weak imageView] image in
            guard let imageView = imageView else { return }
            self?.updateImageView(imageView, inRowAt: indexPath, with: image)
        }
    }
    
    private func updateImageView(_ imageView: UIImageView, inRowAt indexPath: IndexPath, with image: UIImage) {
        guard imageLoads.removeValue(forKey: imageView) != nil else { return imageView.image = image }
        tableView.reloadRows(at: [indexPath], with: .none)
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
            configureCell(cell, forRowAt: indexPath, with: viewModel)
        }
        return cell
    }
}
