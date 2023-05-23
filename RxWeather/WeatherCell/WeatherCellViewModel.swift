//
//  WeatherCellViewModel.swift
//  RxWeather
//
//  Created by Павло Сніжко on 20.05.2023.
//

import Foundation
import UIKit

class WeatherCellViewModel {
    let weatherImage: UIImage
    let temperature: String
    let description: String
    let dateString: String
    
    init(weatherImage: UIImage, temperature: String, description: String, dateString: String) {
        self.weatherImage = weatherImage
        self.temperature = temperature
        self.description = description
        self.dateString = dateString
    }
}
