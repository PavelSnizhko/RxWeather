//
//  Colors.swift
//  RxWeather
//
//  Created by Павло Сніжко on 22.05.2023.
//

import UIKit

enum Color {
    case mainPurple
    case textColor
    case secondaryBackground
    case darkerSecondaryBackground
    case secondaryForegroundColor
}

extension Color {
    var value: UIColor {
        get {
            switch self {
            case .textColor:
                return UIColor(hex: "F5F5F5")
            case .mainPurple:
                return UIColor(hex: "4B3EAE")
            case .secondaryBackground:
                return UIColor(hex: "DBD9F2")
            case .darkerSecondaryBackground:
                return UIColor(hex: "D4D1F0")
            case .secondaryForegroundColor:
                return UIColor(hex: "DBD9F2")
            }
        }
    }
}


