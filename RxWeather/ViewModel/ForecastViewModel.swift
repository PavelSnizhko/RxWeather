//
//  ForecastViewModel.swift
//  RxWeather
//
//  Created by Павло Сніжко on 26.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

protocol ForecastRequsting {
    func getForecast(by location: Location) -> Observable<WeatherContainer>
}

struct ForecastViewModel {
    private let networkService: ForecastRequsting
    private let locationService: LocationProviding
    
    init(networkService: ForecastRequsting, locationService: LocationProviding) {
        self.networkService = networkService
        self.locationService = locationService
        
    }
    
    func groupWeatherByDay(weatherList: [WeatherList]) -> [String : [WeatherList]] {
        var groupedWeather: [String: [WeatherList]] = [:]
        
        for weather in weatherList {
            let date = DateFormatHelper.dateFromUTC(dt: weather.dt)
            let day = DateFormatHelper.dateFormatter.string(from: date)
            
            if groupedWeather[day] == nil {
                groupedWeather[day] = [weather]
            } else {
                groupedWeather[day]?.append(weather)
            }
        }
        
        return groupedWeather
    }
    
    func filterMaxTemperature(weatherByDay: [String: [WeatherList]]) -> [String: WeatherList] {
        var filteredWeather: [String: WeatherList] = [:]
        
        for (date, weatherList) in weatherByDay {
            let maxTemperature = weatherList.reduce(Double.leastNormalMagnitude) { max($0, $1.main.tempMax) }
            let filteredList = weatherList.filter { $0.main.tempMax == maxTemperature }
            filteredWeather[date] = filteredList.first
        }
        
        return filteredWeather
    }
    
    func prepareWeatherCellViewModels() -> Observable<[WeatherCellViewModel]> {
        locationService.locationObservable
            .flatMap {
                networkService.getForecast(by: $0.toLocation())
            }
            .map { weatherContainer -> [String: WeatherList] in
                let weathersDict = groupWeatherByDay(weatherList: weatherContainer.list)
                let maxTempratureWetherDict = filterMaxTemperature(weatherByDay: weathersDict)
                
                return maxTempratureWetherDict
            }
            .map { weatherDict in
                weatherDict.compactMap { dateString, weatherList -> WeatherCellViewModel? in
                    guard let weather = weatherList.weather.first else {
                        return nil
                    }
                    
                    //TODO: change the way of providing link
                    let iamgeURL = URL(string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png")!
                    
                    return WeatherCellViewModel(imageURL: iamgeURL,
                                                temperature: String(weatherList.main.temp),
                                                description: weather.description,
                                                dateString: dateString)
                }.sorted { firstViewModel, secondViewModel in
                    guard let firstDate = DateFormatHelper.dateFormatter.date(from: firstViewModel.dateString),
                          let secondDate = DateFormatHelper.dateFormatter.date(from: secondViewModel.dateString) else {
                        return false
                    }
                    
                    return firstDate < secondDate
                }
            }
    }
    
}

extension ForecastViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let wetherCellViewodels: Observable<[WeatherCellViewModel]>
        let location: Driver<String>
        let time: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let viewModels = input.viewDidLoad.flatMap(prepareWeatherCellViewModels)
        let location = locationService.cityObservable.asDriver(onErrorJustReturn: "")
        
        let currentTimeObservable = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .map { _ in
                return Int(Date().timeIntervalSince1970)
            }
        
        let time = currentTimeObservable
            .map{currentTime -> String in
                return DateFormatHelper.retrieveTime(from: currentTime)
            }.asDriver(onErrorJustReturn: "")
        
        let output = Output(wetherCellViewodels: viewModels, location: location, time: time)
        
        return output
    }
}



