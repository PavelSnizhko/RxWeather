//
//  UIFont+NunitoSansType.swift
//  RxWeather
//
//  Created by Павло Сніжко on 21.05.2023.
//

import UIKit

extension UIFont {

    public enum NunitoSansType: String {
        case extraboldItalic = "Italic_ExtraBold-Italic"
        case semiboldItalic = "Italic_SemiBold-Italic"
        case semibold = "_SemiBold"
        case regular = "_Regular"
        case lightItalic = "Italic_Light-Italic"
        case light = "_Light"
        case italic = "Italic"
        case extraBold = "_ExtraBold"
        case boldItalic = "Italic_Bold-Italic"
        case bold = "_Bold"
    }

    static func NunitoSans(_ type: NunitoSansType = .regular, size: CGFloat = UIFont.systemFontSize) -> UIFont {
        return UIFont(name: "NunitoSans-12ptExtraLight\(type.rawValue)", size: size)!
    }

    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }

    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }

}
