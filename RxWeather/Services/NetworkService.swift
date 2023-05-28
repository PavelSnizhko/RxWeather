//
//  WeatherService.swift
//  RxWeather
//
//  Created by Павло Сніжко on 25.05.2023.
//

import Foundation
import RxSwift
import RxCocoa

enum RequestsConstant: String {
    case schema = "https"
    case host = "api.openweathermap.org"
    case APIKey = "eb0db420f68bf3b425633d9d4070a0b4" //TODO: move to safer place
    
    enum Units: String {
        case standard, metric, imperial
    }
    
    enum Exclude: String {
        case minutely, hourly, daily, alerts, current
    }
    
    enum RelativePath: String {
        case forecatstWeatherPath = "/data/2.5/forecast"
        case currentWeathersPath = "/data/2.5/weather"
        case currentWeathersPathForGroupCities = "/data/2.5/group"
        case dailyForecastPath = "/data/2.5/onecall"
    }
}

enum WeatherError: String, Error {
    case cityByNameError = "Something wrong with city data."
    case serverError = "Something wrong with a server."
    case badUrl = "Bad url."
    case badURLItems = "Seems something wrong with url items."
}

class NetworkService {
    private let session: URLSession = .shared
    
    private lazy var baseURL: URL? = {
        URL(string: RequestsConstant.schema.rawValue + "://" + RequestsConstant.host.rawValue)
    }()
    
    private func fetchData<T: Codable>(relativePath: RequestsConstant.RelativePath,
                                       queryItems: [URLQueryItem]) -> Observable<T> {
        
        guard let url = buildURL(relativePath: relativePath.rawValue, queryItems: queryItems) else {
            return Observable.error(WeatherError.badUrl)
        }
        
        return session.rx.data(request: URLRequest(url: url))
            .map { data -> T in
                let decoder = JSONDecoder()
                
                print("Received json: \(String(decoding: data, as: UTF8.self))")
                
                
                let response = try decoder.decode(T.self, from: data)
                return response
            }
            .subscribe(on: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
    }
    
    private func buildURL(relativePath: String, queryItems: [URLQueryItem]) -> URL? {
        var url = URL(string: relativePath, relativeTo: baseURL)
        url?.append(queryItems: queryItems)
        
        return url
    }
}

extension NetworkService: CurrentWeatherRequesting, ForecastRequsting {
    
    func getCurrentWeather(by location: Location) -> Observable<CurrentWeatherContainer> {
        guard let apiKey = Configuration.apiKey else {
            return Observable.error(WeatherError.badURLItems)
        }
        let queryItems = [URLQueryItem(name: "lat", value: "\(location.latitude)"),
                          URLQueryItem(name: "lon", value: "\(location.longitude)"),
                          URLQueryItem(name: "appid", value: apiKey)]
        return fetchData(relativePath: .currentWeathersPath, queryItems: queryItems)
    }
    
    func getForecast(by location: Location) -> Observable<WeatherContainer> {
        guard let apiKey = Configuration.apiKey else {
            return Observable.error(WeatherError.badURLItems)
        }
        let queryItems = [URLQueryItem(name: "lat", value: "\(location.latitude)"),
                          URLQueryItem(name: "lon", value: "\(location.longitude)"),
                          URLQueryItem(name: "appid", value: apiKey)]
        return fetchData(relativePath: .forecatstWeatherPath, queryItems: queryItems)
    }
    
    func getHourlyForecast(by location: Location) -> Observable<HourlyForecastContainer> {
        guard let apiKey = Configuration.apiKey else {
            return Observable.error(WeatherError.badURLItems)
        }
        let queryItems = [URLQueryItem(name: "lat", value: "\(location.latitude)"),
                          URLQueryItem(name: "lon", value: "\(location.longitude)"),
                          URLQueryItem(name: "appid", value: apiKey),
                          URLQueryItem(name: "exclude", value: "minutely,daily,alerts")]
        
        return fetchData(relativePath: .dailyForecastPath, queryItems: queryItems)
    }
    
}
