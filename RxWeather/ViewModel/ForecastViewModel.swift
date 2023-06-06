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
    private let weatherProvider: ForecastRequsting
    private let city: String
    private let location: Location
    
    private let activityIndicator = ActivityIndicator()
    
    init(weatherProvider: ForecastRequsting, location: Location, city: String) {
        self.weatherProvider = weatherProvider
        self.city = city
        self.location = location
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
        weatherProvider.getForecast(by: location)
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
                    
                    let iamgeURL = WeatherIconProvider.makeImageURL(from: weather.icon)
                    
                    return WeatherCellViewModel(imageURL: iamgeURL,
                                                temperature: String(weatherList.main.temp),
                                                description: weather.description,
                                                dateString: dateString)
                }
                .sorted { firstViewModel, secondViewModel in
                    guard let firstDate = DateFormatHelper.dateFormatter.date(from: firstViewModel.dateString),
                          let secondDate = DateFormatHelper.dateFormatter.date(from: secondViewModel.dateString) else {
                        return false
                    }
                    
                    return firstDate < secondDate
                }
            }
            .trackActivity(activityIndicator)
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
        let loadingDriver: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let viewModels = input.viewDidLoad.flatMap(prepareWeatherCellViewModels)
        let location = Observable.just(city)
            .asDriver(onErrorJustReturn: "")
        
        let initialTime = Int(Date().timeIntervalSince1970)

        let currentTimeObservable = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .map {
                initialTime + $0
            }
            .startWith(initialTime)
        
        let time = currentTimeObservable
            .map{currentTime -> String in
                return DateFormatHelper.retrieveTime(from: currentTime)
            }
            .asDriver(onErrorJustReturn: "")
        
        let output = Output(wetherCellViewodels: viewModels,
                            location: location,
                            time: time,
                            loadingDriver: activityIndicator.asDriver(onErrorJustReturn: false))
        
        return output
    }
}



