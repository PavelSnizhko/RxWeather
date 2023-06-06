//
//  WeatherContainerViewModel.swift
//  RxWeather
//
//  Created by Павло Сніжко on 06.06.2023.
//

import Foundation

class WeatherContainerViewModel {
    
    private let location: Location
    
    private let weatherProvider = WeatherProvider()
    
    private let city: String

    lazy var forecastViewModel = ForecastViewModel(weatherProvider: weatherProvider,
                                                   location: location,
                                                   city: city)
    
    lazy var currentWeatherViewModel = CurrentWeatherViewModel(weatherProvider: weatherProvider, location: location)
    
    lazy var metricViewModel = MetricViewModel(hourlyForecast: currentWeatherViewModel.hourlyForecast)

    init(location: Location, city: String) {
        self.location = location
        self.city = city
    }
}
