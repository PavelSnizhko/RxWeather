//
//  MetricViewModel.swift
//  RxWeather
//
//  Created by Павло Сніжко on 22.05.2023.
//

import UIKit
import RxSwift

struct MetricCellViewModel {
    var icon: UIImage?
    let valueString: String
    let title: String

    var cellSize: CGSize {
        let width = maxLabelWidth()
        return CGSize(width: width, height: 52)
    }
    
    private func maxLabelWidth() -> CGFloat {
        let valueLabel = UILabel(frame: CGRect.zero)
        valueLabel.text = valueString
        valueLabel.font = UIFont.NunitoSans(.bold, size: 12)
        valueLabel.sizeToFit()
        
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.text = title
        titleLabel.font = UIFont.NunitoSans(.bold, size: 12)
        titleLabel.sizeToFit()
        
        return max(valueLabel.frame.width, titleLabel.frame.width)
    }
}

struct MetricViewModel {
    //    let currentWeather: Hourly
    let hourlyForecast: Observable<HourlyForecastContainer>
    
    init(hourlyForecast: Observable<HourlyForecastContainer>) {
        self.hourlyForecast = hourlyForecast
    }
}

extension MetricViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let wetherCellViewodels: Observable<[MetricCellViewModel]>
    }
    
    func transform(input: Input) -> Output {
        let wetherCellViewodels = hourlyForecast
            .map { horlyForecast in
                horlyForecast.currentWeather
            }
            .map(retriveMetricCellViewModels)
            .retry()
        
        return Output(wetherCellViewodels: wetherCellViewodels)
    }
    
    private func retriveMetricCellViewModels(currentWeather: Hourly) -> [MetricCellViewModel] {
        [
            MetricCellViewModel(icon: MetricIcon.humidity.icon, valueString: "\(currentWeather.humidity)%", title: MetricIcon.humidity.rawValue),
            MetricCellViewModel(icon: MetricIcon.visibility.icon, valueString: "\(convertToKm(from: currentWeather.visibility)) km", title: MetricIcon.visibility.rawValue),
            MetricCellViewModel(icon: MetricIcon.pressure.icon, valueString: "\(currentWeather.pressure)", title: MetricIcon.pressure.rawValue),
            MetricCellViewModel(icon: MetricIcon.humidity.icon, valueString: "\(currentWeather.humidity) km/h", title: MetricIcon.wind.rawValue)
        ]
    }
    private func convertToKm(from meters: Int) -> Float {
        Float(meters) / 1000.0
    }
}

enum MetricIcon: String, CaseIterable {
    case humidity = "Humidity"
    case visibility = "Visibility"
    case pressure = "Air Prressure"
    case wind = "Wind"
    
    var icon: UIImage? {
        switch self {
        case .humidity:
            return UIImage(named: "carbon_humidity")
        case .visibility:
            return UIImage(named: "ic_round-visibility")
        case .pressure:
            return UIImage(named: "ion_speedometer")
        case .wind:
            return UIImage(named: "tabler_wind")
        }
    }
}
