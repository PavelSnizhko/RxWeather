//
//  ViewController.swift
//  RxWeather
//
//  Created by Павло Сніжко on 20.05.2023.
//

import UIKit
import RxSwift

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

class WeatherContainerViewController: UIViewController {
    private let viewModel: WeatherContainerViewModel
    
    init(viewModel: WeatherContainerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var weatherViewController: UIViewController = {
        let vc = WeatherViewController()
        vc.forecastViewModel = viewModel.forecastViewModel
        return vc
    }()
    
    lazy var currentWeatherViewController: UIViewController =  {
        let vc = CurrentWeatherViewController()
        vc.viewModel = viewModel.currentWeatherViewModel
        return vc
    }()
    
    lazy var metricViewController: UIViewController = {
        let vc = MetricsViewController()
        vc.viewModel = viewModel.metricViewModel
        return vc
    }()
    
    private let disposeBag = DisposeBag()
    
    private lazy var metricsView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildrenViewControllers()
        // Do any additional setup after loading the view.
    }
    
    func addChildrenViewControllers() {
        self.add(weatherViewController)
        weatherViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.add(currentWeatherViewController)
        currentWeatherViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.add(metricViewController)
        metricViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up constraints for childViewController1's view
        NSLayoutConstraint.activate([
            weatherViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            weatherViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherViewController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.64)
        ])
        
        // Set up constraints for childViewController2's view
        NSLayoutConstraint.activate([
            currentWeatherViewController.view.topAnchor.constraint(equalTo: weatherViewController.view.bottomAnchor),
            currentWeatherViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            currentWeatherViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currentWeatherViewController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.36)
        ])
        
        NSLayoutConstraint.activate([
            metricViewController.view.heightAnchor.constraint(equalToConstant: 100),
            metricViewController.view.widthAnchor.constraint(equalToConstant: 315),
            metricViewController.view.topAnchor.constraint(equalTo: weatherViewController.view.bottomAnchor, constant: -65),
            metricViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}

