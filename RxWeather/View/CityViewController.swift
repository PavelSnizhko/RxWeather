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
    private let tableView = UITableView()
    private var searchBar = UISearchBar()
    
    private let viewModel = CityViewModel()
        
    private var disposeBag: DisposeBag!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupBindings()
    }
    
    
    func setUI() {
        view.backgroundColor = .white
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.isHidden = false
    }
    
    func setupBindings() {
        let text = searchBar.rx.text
            .orEmpty // Converts the optional text to a non-optional
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // Adds a debounce to avoid rapid changes
            .distinctUntilChanged() // Filters out duplicate consecutive elements
        
        let input = CityViewModel.Input(text: text)
        let output = viewModel.transform(input: input)

        disposeBag = DisposeBag {
            output.citiesDriver
                .drive(tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (_, city, cell) in
                    guard let name = city.name,
                          let country = city.country else {
                        return
                    }
                    cell.textLabel?.text = "\(name), \(country)"
                }
            
            output.isNeededToShowCityListDriver
                .drive(tableView.rx.isHidden)
        }
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
    enum CityError: String, Error {
        case notFoundCity = "There aren't cities"
    }
    
    struct Input {
        let text: Observable<String>
    }
    
    struct Output {
        let isNeededToShowCityListDriver: Driver<Bool>
        let citiesDriver: Driver<[City]>
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
        
        
        let citiesDriver = input.text
            .filter { $0.count >= 2 }
            .flatMap { [unowned self] text in
                self.searchText(searchText: text)
            }
            .asDriver(onErrorJustReturn: [])
        
        return .init(isNeededToShowCityListDriver: isNeededToShowCityListDriver, citiesDriver: citiesDriver)
    }
    
    func searchText(searchText: String) -> Observable<[City]> {
        var predicate: NSPredicate = NSPredicate()
        predicate = NSPredicate(format: "name contains[c] '\(searchText)'")
        
        let fetchRequest = City.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            let cities = try context.fetch(fetchRequest)
            return .just(cities)
        } catch {
            return .error(CityError.notFoundCity)
        }
        
    }
}
