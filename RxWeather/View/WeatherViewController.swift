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
        label.isHidden = true
        return label
    }()
    
    private let timeLabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.semibold, size: 16)
        label.isHidden = true
        return label
    }()
    
    private lazy var geoMetaStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [locationLabel, timeLabel])
        stackview.axis = .vertical
        stackview.alignment = .center
        stackview.isHidden = true
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
        collectionView.isHidden = true
        // Set up collection view properties, such as content inset, delegate, etc.
        return collectionView
    }()
    
    private let loaderView: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        return loader
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
            collectionView.topAnchor.constraint(equalTo: geoMetaStackView.bottomAnchor, constant: 10),
            collectionView.heightAnchor.constraint(equalToConstant: 300),
        ])
        
        view.addSubview(loaderView)
        NSLayoutConstraint.activate([
            loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }
    
    private func setupBindings() {
        disposeBag = DisposeBag {
            let output = forecastViewModel.transform(input: .init(viewDidLoad: rx.viewDidLoad))
            
            output.wetherCellViewodels
                .bind(to: collectionView.rx.items(cellIdentifier: WeatherCell.reuseIdentifier, cellType: WeatherCell.self)) { index, viewModel, cell in
                cell.viewModel = viewModel
            }
            
            output.location.drive(locationLabel.rx.text)
            output.time.drive(timeLabel.rx.text)
            
            output.loadingDriver.drive { [weak self] isLoading in
                self?.processLoading(with: isLoading)
            }
        }
    }
    
    private func processLoading(with isLoading: Bool) {
        let viewsToShowOrHide = [locationLabel, timeLabel, geoMetaStackView, collectionView]
        if !isLoading {
            loaderView.stopAnimating()
            viewsToShowOrHide.forEach { $0.isHidden = false }
        } else {
            loaderView.startAnimating()
            viewsToShowOrHide.forEach { $0.isHidden = true }
        }
    }
    
}

extension WeatherViewController: UICollectionViewDelegate {
    
}

