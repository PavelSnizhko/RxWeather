//
//  WeatherViewController.swift
//  RxWeather
//
//  Created by Павло Сніжко on 20.05.2023.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController {
        
    var forecastViewModel: ForecastViewModel! {
        didSet {
            setupBindings()
        }
    }
    
    private var disposeBag: DisposeBag!
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.secondaryBackground.value
        return view
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.bold, size: 24)
        return label
    }()
    
    private let timeLabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.semibold, size: 16)
        return label
    }()
    
    private lazy var geoMetaStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [locationLabel, timeLabel])
        stackview.axis = .vertical
        stackview.alignment = .center
        return stackview
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 238, height: 300)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 43
        layout.minimumLineSpacing = 43
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        // Set up collection view properties, such as content inset, delegate, etc.
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
        
        locationLabel.text = "Pasuruan"
        timeLabel.text = "17.45 PM"
        
        containerView.addSubview(geoMetaStackView)
        geoMetaStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            geoMetaStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            geoMetaStackView.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor),
        ])
        
        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: WeatherCell.reuseIdentifier)
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: geoMetaStackView.bottomAnchor, constant: 30),
            collectionView.heightAnchor.constraint(equalToConstant: 300),
        ])
        
    }
    
    func setupBindings() {
        disposeBag = DisposeBag {
            forecastViewModel.transform(input: .init(viewDidLoad: rx.viewDidLoad))
                .wetherCellViewodels
                .bind(to: collectionView.rx.items(cellIdentifier: WeatherCell.reuseIdentifier, cellType: WeatherCell.self)) { index, viewModel, cell in
                cell.viewModel = viewModel
            }
            
        }
    }
    
}

extension WeatherViewController: UICollectionViewDelegate {
    
}

