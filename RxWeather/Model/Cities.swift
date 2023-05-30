//
//  Cities.swift
//  RxWeather
//
//  Created by Павло Сніжко on 29.05.2023.
//

import Foundation

// MARK: - Cities
struct Cities: Codable {
    let cities: [City]
}

// MARK: - City

extension Cities {
    
    struct City: Codable {
        let country, name, lat, lng: String
    }
    
}


