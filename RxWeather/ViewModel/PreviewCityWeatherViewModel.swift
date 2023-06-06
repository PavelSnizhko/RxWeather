//
//  PreviewCityWeatherViewModel.swift
//  RxWeather
//
//  Created by Павло Сніжко on 06.06.2023.
//

import Foundation

struct PreviewCityWeatherViewModel {
    let weatherCellViewModel: WeatherCellViewModel
    let city: City
    
    var cityName: String? {
        city.name
    }
}
