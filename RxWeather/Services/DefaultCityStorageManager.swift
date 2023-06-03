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

    func markCitySelected(_ city: City)
    func removeCityFromSelected(_ city: City)
    func addCitiesToStorage(cities: [CityModel])
    func searchText(searchText: String) -> Observable<[City]>
    func getSearchingCity(for index: Int) -> City
    
}

class DefaultCityStorageManager: DefaultCityManagable {
    
    var defaultCities: [City] {
        fetchSelectedCities()
    }
    
    @Storage(key: "isCitiesLoaded", defaultValue: false)
    private(set) var isCitiesLoaded: Bool
    
    private var searchingCities: [City] = []
    private var cities: [City] = []

    private let context = (UIApplication.shared.delegate as! AppDelegate).coreDataStack.managedContext
    
    func getSearchingCity(for index: Int) -> City {
        searchingCities[index]
    }
    
    func markCitySelected(_ city: City) {
        city.isSelected.toggle()
        
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
    func fetchSelectedCities() -> [City] {
        let fetchRequest = City.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isSelected == %@", NSNumber(value: true))
        
        do {
            let cities = try context.fetch(fetchRequest)
            return cities
        } catch {
            print("Error fetching city: \(error.localizedDescription)")
            return []
        }
    }
    
    func removeCityFromSelected(_ city: City) {
        do {
            let city = try context.existingObject(with: city.objectID)
        } catch {
            print("Error fetching city: \(error.localizedDescription)")
        }
        
        city.isSelected.toggle()
        
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
    func addCitiesToStorage(cities: [CityModel]) {
        
        for city in cities {
            let newCity = City(context: context)
            newCity.country = city.country
            newCity.name = city.name
            newCity.lat = city.lat
            newCity.lng = city.lng
            newCity.isSelected = false
            
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
