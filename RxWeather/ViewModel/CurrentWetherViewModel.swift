//
//  CurrentWetherViewModel.swift
//  RxWeather
//
//  Created by Павло Сніжко on 26.05.2023.
//

import RxSwift
import UIKit

protocol CurrentWeatherRequesting {
    func getHourlyForecast(by location: Location) -> Observable<HourlyForecastContainer>
}

struct CurrentWeatherViewModel {
    private let weatherProvider: CurrentWeatherRequesting
    let hourlyForecast: Observable<HourlyForecastContainer>
    
    var metricsViewModel: MetricViewModel!
    
    init(weatherProvider: CurrentWeatherRequesting, location: Location) {
        self.weatherProvider = weatherProvider
        hourlyForecast = weatherProvider.getHourlyForecast(by: location).share()
    }
    
    func getWeatherCellViewModels() -> Observable<[WeatherCellViewModel]> {
        return hourlyForecast
            .map { currentWeatherContainer -> [WeatherCellViewModel] in
                currentWeatherContainer.hourly.compactMap { horlyWeather -> WeatherCellViewModel? in
                    guard let weather = horlyWeather.weather.first else {
                        return nil
                    }
                    
                    let iamgeURL = URL(string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png")!
                    
                    let date = DateFormatHelper.dateFromUTC(dt: horlyWeather.dt)
                    let dateString = DateFormatHelper.hourlyDateFormatter.string(from: date)
                    
                    return WeatherCellViewModel(imageURL: iamgeURL,
                                                temperature: String(horlyWeather.temp),
                                                description: "",
                                                dateString: dateString)
                }
                .sorted(by: { firstViewModel, secondViewModel in
                    guard let firstDate = DateFormatHelper.dateFormatter.date(from: firstViewModel.dateString),
                          let secondDate = DateFormatHelper.dateFormatter.date(from: secondViewModel.dateString) else {
                        return false
                    }
                    
                    return firstDate < secondDate
                })
            }
    }
}

extension CurrentWeatherViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let wetherCellViewodels: Observable<[WeatherCellViewModel]>
    }
    
    func transform(input: Input) -> Output {
        
        let output = Output(wetherCellViewodels: input.viewDidLoad.flatMap(getWeatherCellViewModels))
        
        return output
    }
    
}
