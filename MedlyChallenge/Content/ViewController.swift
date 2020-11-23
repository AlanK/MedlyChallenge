//
//  ViewController.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/23/20.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = country.name
        return label
    }()
    
    private lazy var flagView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let unit: CGFloat = 32
        NSLayoutConstraint.activate(
            [view.heightAnchor.constraint(equalToConstant: unit),
             view.widthAnchor.constraint(equalToConstant: unit)]
        )
        if let url = URL(string: country.flagLocation) {
            _ = ImageLoader.shared.loadImage(at: url) { image in view.image = image }
        }
        return view
    }()
    
    private lazy var capitalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = country.capital
        return label
    }()
    
    private lazy var populationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = country.populationText
        return label
    }()

    private lazy var timezonesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = country.timezoneText
        return label
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [nameLabel, flagView, capitalLabel, populationLabel, timezonesLabel]
        )
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 5
        return stack
    }()
    
    private let country: Country
    
    init(_ country: Country) {
        self.country = country
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .sysBackground
        arrangeSubviews()
    }
    
    private func arrangeSubviews() {
        view.addSubview(contentStack)
        NSLayoutConstraint.activate(
            [contentStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
             contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             contentStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        )
    }
}
