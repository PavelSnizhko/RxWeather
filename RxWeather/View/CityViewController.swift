//
//  CityViewController.swift
//  RxWeather
//
//  Created by Павло Сніжко on 30.05.2023.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

class CityViewController: UIViewController {
    
//    private var collectionView: UICollectionView!
    private var searchBar = UISearchBar()
    
    let viewModel = CityViewModel()
    
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupBindings()
    }
    
    func setUI() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupBindings() {
        let text = searchBar.rx.text
            .orEmpty // Converts the optional text to a non-optional
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // Adds a debounce to avoid rapid changes
            .distinctUntilChanged() // Filters out duplicate consecutive elements
            .filter { $0.count >= 2 } // Filter text with two or more letters
        
        let input = CityViewModel.Input(text: text)
        let output = viewModel.transform(input: input)
//
//        disposeBag = DisposeBag {
//
//        }
    }
}

class CityViewModel {
    typealias CityModel = Cities.City
    
    private let cityProvider = CityProvider()
    private let disposeBag = DisposeBag()
    
    private var cities: [City] = []
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).coreDataStack.managedContext
    
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
    struct Input {
        let text: Observable<String>
    }
    
    struct Output {
//        let cities: [City]
    }
    
    func transform(input: Input) -> Output {
        if !isCitiesLoaded {
            cityProvider.fetchCityList()
                .subscribe(onNext: { [weak self] citiesContainer in
                    self?.addCitiesToStorage(cities: citiesContainer.cities)
                })
                .disposed(by: disposeBag)
        }
        
        input.text
            .flatMap { [unowned self] text in
                self.searchText(searchText: text)
            }
            .subscribe(onNext: { _ in
                print("Finish")
            })
            .disposed(by: disposeBag)
        
        return .init()
    }
    
    func searchText(searchText: String) -> Observable<[City]> {
        var predicate: NSPredicate = NSPredicate()
        predicate = NSPredicate(format: "name contains[c] '\(searchText)'")
                
        let fetchRequest = City.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            let cities = try context.fetch(fetchRequest)
            print(cities)
            return .just(cities)
        } catch let error as NSError {
            print("Could not fetch. \(error)")
            return .error(CityError.notFoundCity)
        }
        
    }
}

enum CityError: String, Error {
    case notFoundCity = "There aren't no cities"
}
