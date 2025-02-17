//
//  Configuration.swift
//  RxWeather
//
//  Created by Павло Сніжко on 26.05.2023.
//

import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

extension Configuration {
    
    static var apiKey: String? {
        try? Configuration.value(for: "API_KEY")
    }
    
}
