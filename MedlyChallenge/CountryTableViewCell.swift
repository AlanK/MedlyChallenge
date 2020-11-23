//
//  CountryTableViewCell.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/22/20.
//

import UIKit

/// A table view cell for displaying a country.
class CountryTableViewCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    /// A label suitable for displaying a country's name.
    let countryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()
    
    /// A label suitable for displaying a country's capital, if it has one.
    let capitalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .systemGray
        return label
    }()
    
    /// An image view suitable for displaying a country's flag.
    let flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        let unit: CGFloat = 32
        NSLayoutConstraint.activate(
            [imageView.widthAnchor.constraint(equalToConstant: unit),
             imageView.heightAnchor.constraint(equalToConstant: unit)]
        )
        return imageView
    }()
    
    // MARK: Private Properties
    
    private let margin: CGFloat = 20
    
    private lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [countryLabel, capitalLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = margin / 2
        return stack
    }()
    
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flagImageView)
        NSLayoutConstraint.activate(
            [view.leadingAnchor.constraint(equalTo: flagImageView.leadingAnchor),
             view.trailingAnchor.constraint(equalTo: flagImageView.trailingAnchor),
             view.heightAnchor.constraint(greaterThanOrEqualTo: flagImageView.heightAnchor),
             view.centerYAnchor.constraint(equalTo: flagImageView.centerYAnchor)]
        )
        return view
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageContainerView, labelStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .top
        stack.distribution = .fill
        stack.spacing = margin
        let constraints = [imageContainerView.heightAnchor.constraint(equalTo: stack.heightAnchor),
                           stack.heightAnchor.constraint(equalToConstant: .zero)]
        constraints.forEach { constraint in constraint.priority = .defaultLow }
        NSLayoutConstraint.activate(constraints)
        return stack
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        arrangeSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func arrangeSubviews() {
        [countryLabel, capitalLabel].forEach { label in
            label.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        contentView.addSubview(contentStack)
        let bottomConstraint = contentStack.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -margin
        )
        // Table view cells like to flex their heights when they are being dequeued
        bottomConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate(
            [contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
             contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
             contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
             bottomConstraint]
        )
    }
}
