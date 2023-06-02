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

class CityViewController: UIViewController, UITableViewDelegate {
    
    private let searchResultTableView = UITableView()
    private var searchBar = UISearchBar()
    
    private let citiesTableView = UITableView()
    
    private var buttonWidthConstaint: NSLayoutConstraint!
    private var buttonHeightConstaint: NSLayoutConstraint!

    private lazy var button: UIButton =  {
        let button =  UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = Color.mainPurple.value
        button.setTitle("Use current location", for: .normal)
        button.titleLabel?.font = UIFont.NunitoSans(.bold, size: 12)
        return button
    }()
    
    private let viewModel = CityViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private var disposeBag: DisposeBag!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupBindings()
    }
    
    private func setCitiesTableView() {
        view.addSubview(citiesTableView)
        citiesTableView.translatesAutoresizingMaskIntoConstraints = false
        citiesTableView.register(PreviewCityWeatherCell.self, forCellReuseIdentifier: "PreviewCityWeatherCell")

        NSLayoutConstraint.activate([
            citiesTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            citiesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            citiesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            citiesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    func setUI() {
        title = "Weather in cities"
        view.backgroundColor = .white
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        searchResultTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchResultTableView)
        NSLayoutConstraint.activate([
            searchResultTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            searchResultTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        searchResultTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        searchResultTableView.isHidden = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        setInitialLocationButtonPosition(isCityAdded: false) //TODO: move to binding func
        setCitiesTableView()
    }
    
    private func setInitialLocationButtonPosition(isCityAdded: Bool) {
        guard isCityAdded else {
            setLocationButtonAsBarButton()
            return
        }
        
        buttonWidthConstaint = button.widthAnchor.constraint(equalToConstant: 200)
        buttonHeightConstaint = button.heightAnchor.constraint(equalToConstant: 50)
        let buttonConstaints = [
            buttonWidthConstaint,
            buttonHeightConstaint,
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20)
        ]
        buttonConstaints.forEach {
            $0?.priority = UILayoutPriority(rawValue: 999)
        }
        NSLayoutConstraint.activate(buttonConstaints.compactMap { $0 })
    }
    
    private func setLocationButtonAsBarButton() {
        buttonWidthConstaint = button.widthAnchor.constraint(equalToConstant: 80)
        buttonHeightConstaint = button.heightAnchor.constraint(equalToConstant: 30)
        buttonWidthConstaint.isActive = true
        buttonHeightConstaint.isActive = true
        
        button.setTitle("Location", for: .normal)
        
        let buttonItem = UIBarButtonItem(customView: self.button)
        self.navigationItem.rightBarButtonItem = buttonItem
    }
    
    func setupBindings() {
        let text = searchBar.rx.text
            .orEmpty // Converts the optional text to a non-optional
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // Adds a debounce to avoid rapid changes
            .distinctUntilChanged()
        
        let itemSelection = searchResultTableView.rx.itemSelected.distinctUntilChanged()
        
        let itemDeleted = citiesTableView.rx.itemDeleted.asObservable()

        let input = CityViewModel.Input(text: text,
                                        itemSelected: itemSelection,
                                        useCurrentLocation: button.rx.tap.asObservable(),
                                        itemDeleted: itemDeleted)
        
        let output = viewModel.transform(input: input)
        
//        setInitialLocationButtonPosition(isCityAdded: output.isCityAdded)
        
        disposeBag = DisposeBag {
            citiesTableView.rx.setDelegate(self)
            
            
//            citiesTableView.rx.itemDeleted
            output.citiesDriver
                .drive(searchResultTableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (_, city, cell) in
                    guard let name = city.name,
                          let country = city.country else {
                        return
                    }
                    cell.textLabel?.text = "\(name), \(country)"
                }
            
            
            output.previewCitiesDriver
//                .debug("Preview Cities")
                .do(onNext: {vms in
                    print(vms)
                })
                .drive(citiesTableView.rx.items(cellIdentifier: "PreviewCityWeatherCell",
                                                cellType: PreviewCityWeatherCell.self)) { (_, vm, cell) in
                    print("Shit")
                    cell.viewModel = vm
                }
            
            output.isNeededToShowCityListDriver.drive(onNext: { [weak self] isNeedToHideCityList in
                self?.searchResultTableView.isHidden = isNeedToHideCityList
                self?.citiesTableView.isHidden = !isNeedToHideCityList
            })
            
            output.showWeatherVC.subscribe(onNext: { [weak self] weatherViewModel in
                let vc = WeatherContainerViewController(viewModel: weatherViewModel)
                self?.navigationController?.pushViewController(vc, animated: false)
            })
            
            output.isLocationButtonHiddenDriver.drive(onNext: { [weak self] isHidden in
                UIView.animate(withDuration: 0.3) {
                    guard let self, isHidden == true else {
                        return
                    }
                    
                    self.setLocationButtonAsBarButton()
                }
            })
            
        }
    }
}
