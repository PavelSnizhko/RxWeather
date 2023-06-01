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
    
    typealias CityModel = Cities.City
    
    private let cityProvider = CityProvider()
    private let disposeBag = DisposeBag()
    
    private var cities: [City] = []
    private var searchingCities: [City] = []
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).coreDataStack.managedContext
    
    private let currentLocationProvider: LocationProviding = LocationProvider()
    
    @Storage(key: "isCitiesLoaded", defaultValue: false)
    private var isCitiesLoaded: Bool
    
    func fetchCities() {
        do {
            let cities = try context.fetch(City.fetchRequest())
            print(cities.count)
        } catch {
            print(error)
        }
    }
    
    func addCitiesToStorage(cities: [CityModel]) {
        
        for city in cities {
            let newCity = City(context: context)
            newCity.country = city.country
            newCity.name = city.name
            newCity.lat = city.lat
            newCity.lng = city.lng
            
            self.cities.append(newCity)
        }
        
        do {
            try context.save()
            isCitiesLoaded.toggle()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
        
    }
}

extension CityViewModel: ViewModelType {
    enum CityError: String, Error {
        case notFoundCity = "There aren't cities"
    }
    
    struct Input {
        let text: Observable<String>
        let itemSelected: Observable<IndexPath>
        let useCurrentLocation: Observable<Void>
    }
    
    struct Output {
        let isNeededToShowCityListDriver: Driver<Bool>
        let citiesDriver: Driver<[City]>
        let showWeatherVC: Observable<WeatherContainerViewModel>
        let isLocationButtonHiddenDriver: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        if !isCitiesLoaded {
            cityProvider.fetchCityList()
                .subscribe(onNext: { [weak self] citiesContainer in
                    self?.addCitiesToStorage(cities: citiesContainer.cities)
                })
                .disposed(by: disposeBag)
        }
        
        let isNeededToShowCityListDriver = input.text
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: false)
        
        let isLocationButtonHiddenDriver = input.text.map {
            !$0.isEmpty
        }.asDriver(onErrorJustReturn: false)
        
        let citiesDriver = input.text
            .filter { $0.count >= 2 }
            .flatMap { [unowned self] text in
                self.searchText(searchText: text)
            }
            .asDriver(onErrorJustReturn: [])
        
        let viewModelObservable = getWeatherViewModel(itemSelected: input.itemSelected, useCurrentLocation: input.useCurrentLocation)
        
        return .init(isNeededToShowCityListDriver: isNeededToShowCityListDriver,
                     citiesDriver: citiesDriver,
                     showWeatherVC: viewModelObservable,
                     isLocationButtonHiddenDriver: isLocationButtonHiddenDriver)
    }
    
    private func getWeatherViewModel(itemSelected: Observable<IndexPath>, useCurrentLocation: Observable<Void>) -> Observable<WeatherContainerViewModel> {
        let cityBySelection = itemSelected
            .compactMap { [weak self] indexPath in
                self?.searchingCities[indexPath.row]
            }
        
        let locationByCity = cityBySelection.compactMap({ city -> Location? in
            guard let stringLatitude = city.lat,
                  let stringLongitude = city.lng,
                  let latitude = Double(stringLatitude),
                  let longitude = Double(stringLongitude) else {
                return nil
            }
            return Location(latitude: latitude, longitude: longitude)
        })
        
        let cityByCurrentLocation = useCurrentLocation
            .flatMap { [currentLocationProvider] _ in
                currentLocationProvider.cityObservable
            }
        
        let cityStringObservable = Observable.merge(cityBySelection.compactMap(\.name), cityByCurrentLocation)
        
        let currentLocation = useCurrentLocation.flatMap { [currentLocationProvider] _ in
            currentLocationProvider.locationObservable
                .map { $0.toLocation() }
        }
        
        let showWeatherVC = Observable.merge(itemSelected.map { _ in }, useCurrentLocation)
        
        let locationObservable = Observable.merge(locationByCity, currentLocation)
        
        let weatherViewModel = Observable.combineLatest(locationObservable, cityStringObservable) { location, city in
            WeatherContainerViewModel(location: location, city: city)
        }
        
        let viewModelObservable = showWeatherVC.flatMap { _ in
            weatherViewModel
        }
        return viewModelObservable
    }
    
    func searchText(searchText: String) -> Observable<[City]> {
        var predicate: NSPredicate = NSPredicate()
        predicate = NSPredicate(format: "name contains[c] '\(searchText)'")
        
        let fetchRequest = City.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            let cities = try context.fetch(fetchRequest)
            self.searchingCities = cities
            return .just(cities)
        } catch {
            return .error(CityError.notFoundCity)
        }
        
    }
}
