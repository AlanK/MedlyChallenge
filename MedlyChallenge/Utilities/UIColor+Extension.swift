//
//  UIColor+Extension.swift
//  MedlyChallenge
//
//  Created by Alan Kantz on 11/22/20.
//

import UIKit

extension UIColor {
    
    /// A background color that is white in iOS 12 and light mode.
    static var sysBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
}
