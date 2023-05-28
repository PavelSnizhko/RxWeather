//
//  WeatherCellViewModel.swift
//  RxWeather
//
//  Created by Павло Сніжко on 20.05.2023.
//

import Foundation
import UIKit
import RxSwift
import Nuke

struct WeatherCellViewModel {
    let weatherImage: Observable<UIImage>
    let fahrenheitTemperature: String
    let description: String
    let dateString: String
    
    var celciusTemperature: String {
        let temperature = convertFahrenheitToCelsius(kelvin: fahrenheitTemperature) ?? 0
        return "\(temperature) °C"
    }
    
    var dayOfWeek: String {
        DateFormatHelper.mapToDayOfWeek(from: dateString)
    }
    
    init(imageURL: URL, temperature: String, description: String, dateString: String) {
        self.fahrenheitTemperature = temperature
        self.description = description
        self.dateString = dateString
        
        self.weatherImage = ImagePipeline.shared.rx.loadImage(with: imageURL)
            .compactMap { $0.image }
            .asObservable()
    }
    
    private func convertFahrenheitToCelsius(kelvin: String) -> Int? {
        guard let kelvin = Double(kelvin) else {
            return nil
        }
        
        let celsius = kelvin - 273.15
        return Int(floor(celsius))
    }
}
