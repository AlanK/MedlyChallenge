//
//  AppDelegate.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/20/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let rootVC = UINavigationController(rootViewController: InitialViewController())
        rootVC.navigationBar.prefersLargeTitles = true
        let localWindow = UIWindow()
        window = localWindow
        localWindow.rootViewController = rootVC
        localWindow.makeKeyAndVisible()
        return true
    }
}

