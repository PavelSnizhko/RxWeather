//
//  WeatherProvider.swift
//  RxWeather
//
//  Created by Павло Сніжко on 30.05.2023.
//

import Foundation
import NetworkLibrary
import RxSwift

class WeatherProvider: CurrentWeatherRequesting, ForecastRequsting {
    
    private lazy var networkManager = NetworkFacade()
    
    private let baseURLString = "https://api.openweathermap.org"

    func getHourlyForecast(by location: Location) -> Observable<HourlyForecastContainer> {
        let endpoint = baseURLString + RelativePath.dailyForecastPath.rawValue
        
        guard let apiKey = Configuration.apiKey else {
            return Observable.error(WeatherError.badURLItems)
        }
        let queryItems = [URLQueryItem(name: "lat", value: "\(location.latitude)"),
                          URLQueryItem(name: "lon", value: "\(location.longitude)"),
                          URLQueryItem(name: "appid", value: apiKey),
                          URLQueryItem(name: "exclude", value: "minutely,daily,alerts")]
        
        let requestMetaData = RequestMetaData(endpoint: endpoint, method: .get, body: nil, headers: nil, queryItems: queryItems)
        let resource = Resource(requestMetaData: requestMetaData, decodingType: HourlyForecastContainer.self)
        
        return networkManager.execute(resource: resource)
    }
    
    func getForecast(by location: Location) -> Observable<WeatherContainer> {
        let endpoint = baseURLString + RelativePath.forecatstWeatherPath.rawValue
        
        guard let apiKey = Configuration.apiKey else {
            return Observable.error(WeatherError.badURLItems)
        }
        let queryItems = [URLQueryItem(name: "lat", value: "\(location.latitude)"),
                          URLQueryItem(name: "lon", value: "\(location.longitude)"),
                          URLQueryItem(name: "appid", value: apiKey)]
        
        let requestMetaData = RequestMetaData(endpoint: endpoint, method: .get, body: nil, headers: nil, queryItems: queryItems)
        let resource = Resource(requestMetaData: requestMetaData, decodingType: WeatherContainer.self)
        
        return networkManager.execute(resource: resource)
    }
    
    func getCurrentWeatherForecast(by location: Location) -> Observable<CurrentWeatherContainer> {
        let endpoint = baseURLString + RelativePath.forecatstWeatherPath.rawValue
        
        guard let apiKey = Configuration.apiKey else {
            return Observable.error(WeatherError.badURLItems)
        }
        let queryItems = [URLQueryItem(name: "lat", value: "\(location.latitude)"),
                          URLQueryItem(name: "lon", value: "\(location.longitude)"),
                          URLQueryItem(name: "appid", value: apiKey)]
        
        let requestMetaData = RequestMetaData(endpoint: endpoint, method: .get, body: nil, headers: nil, queryItems: queryItems)
        let resource = Resource(requestMetaData: requestMetaData, decodingType: CurrentWeatherContainer.self)
        
        return networkManager.execute(resource: resource)
    }
    
}

extension WeatherProvider {
    
    enum RelativePath: String {
        case forecatstWeatherPath = "/data/2.5/forecast"
        case currentWeathersPath = "/data/2.5/weather"
        case currentWeathersPathForGroupCities = "/data/2.5/group"
        case dailyForecastPath = "/data/2.5/onecall"
    }
    
    enum WeatherError: String, Error {
        case cityByNameError = "Something wrong with city data."
        case serverError = "Something wrong with a server."
        case badUrl = "Bad url."
        case badURLItems = "Seems something wrong with url items."
    }

}
