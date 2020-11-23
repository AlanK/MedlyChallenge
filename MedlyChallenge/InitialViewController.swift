//
//  InitialViewController.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/22/20.
//

import UIKit

/// The view controller responsible for coordinating the display of the country list.
class InitialViewController: UIViewController {

    // MARK: - Properties
    
    override var navigationItem: UINavigationItem { nav }
    
    // MARK: Private Properties
    
    private let duration: TimeInterval = 0.2
    
    private lazy var nav: UINavigationItem = {
        let nav = UINavigationItem()
        nav.title = "Countries"
        nav.largeTitleDisplayMode = .always
        return nav
    }()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetAndBeginLoading()
    }
    
    // MARK: Private Methods
    
    private func resetAndBeginLoading() {
        addOnlyChild(WaitingViewController())
        loadCountries()
    }
    
    private func addOnlyChild(_ child: UIViewController) {
        for child in children {
            child.willMove(toParent: nil)
            child.removeFromParent()
            child.view.removeFromSuperview()
        }
        view.addSubview(child.view)
        addChild(child)
        child.didMove(toParent: self)
        NSLayoutConstraint.activate(
            [child.view.topAnchor.constraint(equalTo: view.topAnchor),
             child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        )
    }

    private func loadCountries() {
        CountryService.getAll { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let countries = try? result.get() else { return self.displayError() }
                self.displayCountries(countries)
            }
        }
    }
    
    private func displayCountries(_ countries: [Country]) {
        UIView.animate(withDuration: duration) {
            self.addOnlyChild(CountryViewController(countries: countries))
        }
    }
    
    private func displayError() {
        let errorViewController = ErrorViewController()
        errorViewController.delegate = self
        UIView.animate(withDuration: duration) {
            self.addOnlyChild(errorViewController)
        }
    }
}

// MARK: - Error View Controller Delegate

extension InitialViewController: ErrorViewControllerDelegate {
    
    func errorViewControllerDidTryAgain(_ errorViewController: ErrorViewController) {
        resetAndBeginLoading()
    }
}
