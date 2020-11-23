//
//  ErrorViewController.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/22/20.
//

import UIKit

/// A protocol for types interested in the lifecycle of an error view controller.
protocol ErrorViewControllerDelegate: AnyObject {
    /// Notifies the delegate that the error view controller has had its "Try Again" button tapped.
    /// - Parameter errorViewController: The error view controller.
    func errorViewControllerDidTryAgain(_ errorViewController: ErrorViewController)
}

/// A view controller that displays an error message and a "Try Again" button.
class ErrorViewController: UIViewController {
    
    /// The delegate of the error view controller.
    weak var delegate: ErrorViewControllerDelegate?
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Something went wrong."
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "We could not find the list of countries."
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var tryAgainButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tryAgain), for: .touchUpInside)
        button.setTitle("Try Again", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [errorLabel, descriptionLabel, tryAgainButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        arrangeSubviews()
    }
    
    private func arrangeSubviews() {
        view.addSubview(stack)
        NSLayoutConstraint.activate(
            [stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2 / 3)]
        )
    }
    
    @objc private func tryAgain() {
        delegate?.errorViewControllerDidTryAgain(self)
    }
}
