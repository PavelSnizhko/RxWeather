//
//  CurrentWetherViewModel.swift
//  RxWeather
//
//  Created by Павло Сніжко on 26.05.2023.
//

import RxSwift
import RxCocoa
import UIKit

protocol CurrentWeatherRequesting {
    func getHourlyForecast(by location: Location) -> Observable<HourlyForecastContainer>
}

struct CurrentWeatherViewModel {
    private let weatherProvider: CurrentWeatherRequesting
    let hourlyForecast: Observable<HourlyForecastContainer>
    
    var metricsViewModel: MetricViewModel!
    
    private let activityIndicator = ActivityIndicator()
    
    var isLoadingFinished: Observable<Bool> {
        activityIndicator.asObservable()
    }

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
                    
                    let iamgeURL = WeatherIconProvider.makeImageURL(from: weather.icon)
                    
                    let date = DateFormatHelper.dateFromUTC(dt: horlyWeather.dt)
                    let dateString = DateFormatHelper.hourlyDateFormatter.string(from: date)
                    
                    return WeatherCellViewModel(imageURL: iamgeURL,
                                                temperature: String(horlyWeather.temp),
                                                description: weather.description?.capitalized ?? "",
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
            .trackActivity(activityIndicator)
        }
}

extension CurrentWeatherViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let wetherCellViewodels: Observable<[WeatherCellViewModel]>
        let loadingDriver: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let output = Output(wetherCellViewodels: input.viewDidLoad.flatMap(getWeatherCellViewModels),
                            loadingDriver: isLoadingFinished.asDriver(onErrorJustReturn: false))
        
        return output
    }
    
}
