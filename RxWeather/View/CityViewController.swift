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
    
    private lazy var button: UIButton =  {
        let button =  UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = Color.mainPurple.value
        button.setTitle("Use current location", for: .normal)
        button.titleLabel?.font = UIFont.NunitoSans(.bold, size: 12)
        return button
    }()
    
    private let viewModel = CityViewModel()
    
    private var disposeBag: DisposeBag!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupBindings()
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
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20)
        ])
    }
    
    func setupBindings() {
        let text = searchBar.rx.text
            .orEmpty // Converts the optional text to a non-optional
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // Adds a debounce to avoid rapid changes
            .distinctUntilChanged()
        
        let itemSelection = tableView.rx.itemSelected.distinctUntilChanged()
        
        let input = CityViewModel.Input(text: text, itemSelected: itemSelection, useCurrentLocation: button.rx.tap.asObservable())
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
            
            output.showWeatherVC.subscribe(onNext: { [weak self] weatherViewModel in
                let vc = WeatherContainerViewController(viewModel: weatherViewModel)
                self?.navigationController?.pushViewController(vc, animated: false)
            })
            
            output.isLocationButtonHiddenDriver.drive(onNext: { [weak button] isHidden in
                UIView.animate(withDuration: 0.3) {
                    button?.isHidden = isHidden
                }
            })
            
        }
    }
}
