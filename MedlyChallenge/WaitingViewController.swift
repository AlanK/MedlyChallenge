//
//  WaitingViewController.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/22/20.
//

import UIKit

/// A view controller with a centered activity spinner.
class WaitingViewController: UIViewController {
    
    private lazy var activityView: UIView = {
        let view: UIActivityIndicatorView
        if #available(iOS 13, *) {
            view = UIActivityIndicatorView(style: .medium)
        } else {
            view = UIActivityIndicatorView(style: .gray)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        arrangeSubviews()
    }
    
    private func arrangeSubviews() {
        view.addSubview(activityView)
        NSLayoutConstraint.activate(
            [activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
        )
    }
}
