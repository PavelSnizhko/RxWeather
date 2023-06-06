//
//  HourlyForecastContainer.swift
//  RxWeather
//
//  Created by Павло Сніжко on 27.05.2023.
//

import Foundation

// MARK: - HourlyForecastContainer
struct HourlyForecastContainer: Codable {
    let hourly: [Hourly]
    let currentWeather: Hourly
    
    enum CodingKeys: String, CodingKey {
        case hourly
        case currentWeather = "current"
    }
}

// MARK: - Hourly
struct Hourly: Codable {
    let dt: Int
    let temp, feelsLike: Double
    let pressure, humidity: Int
    let dewPoint, uvi: Double
    let clouds, visibility: Int
    let windSpeed: Double
    let windDeg: Int
    let weather: [Weather]

    enum CodingKeys: String, CodingKey {
        case dt, temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case dewPoint = "dew_point"
        case uvi, clouds, visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather
    }
}

extension Hourly {
    
    // MARK: - Weather
    struct Weather: Codable {
        let id: Int
        let icon: String
        let description: String?
    }
    
}
