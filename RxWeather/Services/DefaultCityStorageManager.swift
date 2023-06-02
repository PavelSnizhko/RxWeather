//
//  DefaultCityStorageManager.swift
//  RxWeather
//
//  Created by Павло Сніжко on 01.06.2023.
//

import Foundation
import RxSwift
import UIKit

typealias CityModel = Cities.City

protocol DefaultCityManagable {
    
    var defaultCities: [City] { get }
    var isCitiesLoaded: Bool { get }

    func addCity(_ city: City)
    func removeCity(_ city: City)
    func addCitiesToStorage(cities: [CityModel])
    func searchText(searchText: String) -> Observable<[City]>
    func getSearchingCity(for index: Int) -> City
    
}

class DefaultCityStorageManager: DefaultCityManagable {
    
    @Storage(key: "Cities", defaultValue: [])
    private(set) var defaultCities: [City]
    
    @Storage(key: "isCitiesLoaded", defaultValue: false)
    private(set) var isCitiesLoaded: Bool
    
    private var searchingCities: [City] = []
    private var cities: [City] = []

    private let context = (UIApplication.shared.delegate as! AppDelegate).coreDataStack.managedContext

    var uniqueCities: Set<City> {
        Set<City>(defaultCities)
    }
    
    func getSearchingCity(for index: Int) -> City {
        searchingCities[index]
    }
    
    func addCity(_ city: City) {
        guard !uniqueCities.contains(city) else {
            return
        }
        
        var cities = defaultCities
        cities.append(city)
        defaultCities = cities
    }
    
    func removeCity(_ city: City) {
        guard let index = defaultCities.firstIndex(of: city) else {
            return
        }
        defaultCities.remove(at: index)
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

enum CityError: String, Error {
    case notFoundCity = "There aren't cities"
}
