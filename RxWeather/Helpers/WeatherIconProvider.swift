//
//  WeatherIconProvider.swift
//  RxWeather
//
//  Created by Павло Сніжко on 06.06.2023.
//

import Foundation

final class WeatherIconProvider {
    
    static func makeImageURL(from iconName: String) -> URL {
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(iconName)@2x.png") else {
            assertionFailure("Broken URL")
            return URL(string: "")!
        }
        
        return url
    }
    
}


