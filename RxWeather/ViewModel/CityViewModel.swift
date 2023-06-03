//
//  CityViewModel.swift
//  RxWeather
//
//  Created by Павло Сніжко on 31.05.2023.
//

import RxSwift
import RxCocoa
import CoreData
import UIKit

class CityViewModel {
    private let cityProvider = CityProvider()
    private let disposeBag = DisposeBag()
    
    private let currentLocationProvider: LocationProviding = LocationProvider()
    
    let cityWeatherViewModelSubject = BehaviorSubject<[PreviewCityWeatherViewModel]>(value: [])
    
    //    @Storage(key: "isCityAdded", defaultValue: false)
    //    private var isCityAdded: Bool
    
    private var cityManager: DefaultCityManagable = DefaultCityStorageManager()
    private let weatherProvider: CurrentWeatherRequesting = WeatherProvider()
    
    private func addCityToDefaults(cityObservable: Observable<City>) {
        cityObservable.subscribe(onNext: { [cityManager] city in
            cityManager.markCitySelected(city)
        })
        .disposed(by: disposeBag)
    }
    
    func getPreviewCitiesIfNeeded() {
        let currentWeatherViewModels = cityManager.defaultCities
            .compactMap({ city -> (City, Location)? in
                guard let location = city.location else {
                    return nil
                }
                
                return (city, location)
            })
            .map { (name, location) in
                (name, CurrentWeatherViewModel(weatherProvider: weatherProvider, location: location))
            }
        
        let observables = currentWeatherViewModels.map { (city, vm) in
            vm.getWeatherCellViewModels()
                .compactMap(\.first)
                .map {
                    PreviewCityWeatherViewModel(weatherCellViewModel: $0, city: city)
                }
        }
        
        Observable.combineLatest(observables)
            .subscribe(onNext: { [weak self] viewModels in
                self?.cityWeatherViewModelSubject.onNext(viewModels)
            }).disposed(by: disposeBag)
        
    }
    
    func removeItem(at indexPath: IndexPath) {
        guard var viewModels = try? cityWeatherViewModelSubject.value() else { return }
        
        let viewModel = viewModels.remove(at: indexPath.row)
        
        cityWeatherViewModelSubject.onNext(viewModels)
        cityManager.removeCityFromSelected(viewModel.city)
        
    }
}

extension CityViewModel: ViewModelType {
    
    struct Input {
        let text: Observable<String>
        let itemSelected: Observable<IndexPath>
        let useCurrentLocation: Observable<Void>
        let itemDeleted: Observable<IndexPath>
    }
    
    struct Output {
        let isNeededToShowCityListDriver: Driver<Bool>
        let citiesDriver: Driver<[City]>
        let showWeatherVC: Observable<WeatherContainerViewModel>
        let isLocationButtonHiddenDriver: Driver<Bool>
        let previewCitiesDriver: Driver<[PreviewCityWeatherViewModel]>
    }
    
    func transform(input: Input) -> Output {
        if !cityManager.isCitiesLoaded {
            cityProvider.fetchCityList()
                .subscribe(onNext: { [cityManager] citiesContainer in
                    cityManager.addCitiesToStorage(cities: citiesContainer.cities)
                })
                .disposed(by: disposeBag)
        }
        
        input.itemDeleted.subscribe(onNext: { [weak self] indexPath in
            self?.removeItem(at: indexPath)
        })
        .disposed(by: disposeBag)
        
        let isNeededToShowCityListDriver = input.text
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: false)
        
        let isLocationButtonHiddenDriver = input.text.map {
            !$0.isEmpty
        }
        .asDriver(onErrorJustReturn: false)
        
        let citiesDriver = input.text
            .filter { $0.count >= 2 }
            .flatMap { [cityManager] text in
                cityManager.searchText(searchText: text)
            }
            .asDriver(onErrorJustReturn: [])
        
        let cityBySelection = input.itemSelected
            .compactMap { [cityManager] indexPath in
                cityManager.getSearchingCity(for: indexPath.row)
            }
        
        addCityToDefaults(cityObservable: cityBySelection)
        
        let viewModelObservable = getWeatherViewModel(itemSelected: input.itemSelected,
                                                      useCurrentLocation: input.useCurrentLocation,
                                                      cityBySelection: cityBySelection)
        
        getPreviewCitiesIfNeeded()
        let previewCitiesDriver = cityWeatherViewModelSubject.asObservable().asDriver(onErrorJustReturn: [])
        
        return .init(isNeededToShowCityListDriver: isNeededToShowCityListDriver,
                     citiesDriver: citiesDriver,
                     showWeatherVC: viewModelObservable,
                     isLocationButtonHiddenDriver: isLocationButtonHiddenDriver,
                     previewCitiesDriver: previewCitiesDriver)
    }
    
    private func getWeatherViewModel(itemSelected: Observable<IndexPath>, useCurrentLocation: Observable<Void>, cityBySelection: Observable<City>) -> Observable<WeatherContainerViewModel> {
        
        let locationByCity = cityBySelection.compactMap(\.location)
        
        let cityByCurrentLocation = useCurrentLocation
            .flatMap { [currentLocationProvider] _ in
                currentLocationProvider.cityObservable
            }
        
        let cityStringObservable = Observable.merge(cityBySelection.compactMap(\.name), cityByCurrentLocation).debug("cityStringObservable")
        
        let currentLocation = useCurrentLocation.flatMap { [currentLocationProvider] _ in
            currentLocationProvider.locationObservable
                .map { $0.toLocation() }
        }
        
        let showWeatherVC = Observable.merge(itemSelected.map { _ in }, useCurrentLocation)
        
        let locationObservable = Observable.merge(locationByCity, currentLocation).debug("locationObservable")
        
        let weatherViewModel = Observable.zip(locationObservable, cityStringObservable) { location, city in
            WeatherContainerViewModel(location: location, city: city)
        }
        
        return weatherViewModel
    }
    
}
