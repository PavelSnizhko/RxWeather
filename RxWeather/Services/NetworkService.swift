//
//  WeatherService.swift
//  RxWeather
//
//  Created by Павло Сніжко on 25.05.2023.
//

import Foundation
import RxSwift
import RxCocoa
import NetworkLibrary

enum RequestsConstant: String {
    case schema = "https"
    case weatherHost = "api.openweathermap.org"
    case gitHubHost = "raw.githubusercontent.com"
    
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
    
    private lazy var weatherBaseURL: URL? = {
        URL(string: RequestsConstant.schema.rawValue + "://" + RequestsConstant.weatherHost.rawValue)
    }()
    
    private lazy var cityBaseURL: URL? = {
        URL(string: RequestsConstant.schema.rawValue + "://" + RequestsConstant.gitHubHost.rawValue)
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
        var url = URL(string: relativePath, relativeTo: weatherBaseURL)
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

//MARK: - RX

extension NetworkFacade {
    
    public func execute<T: Decodable>(resource: Resource<T>) -> Observable<T> {
        return Observable.create { observer in
            execute(resource: resource) { result in
                switch result {
                case let .success(decodedModel):
                    observer.onNext(decodedModel)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    public func execute(requestMetaData: RequestMetaData) -> Observable<Data> {
        return Observable.create { observer in
            execute(requestData: requestMetaData) { result in
                switch result {
                case let .success(data):
                    observer.onNext(data)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
}
