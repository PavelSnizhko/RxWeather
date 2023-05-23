//
//  WeatherViewController.swift
//  RxWeather
//
//  Created by Павло Сніжко on 20.05.2023.
//

import Foundation
import UIKit

class WeatherViewController: UIViewController {
    
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
    
    private var weatherData: [WeatherCellViewModel] = [
        .init(weatherImage: UIImage(named: "Sun cloud mid rain")!, temperature: "23", description: "Moon Cloud Fast Wind", dateString: "Sunday, 8 March 2021"),
        .init(weatherImage: UIImage(named: "Big rain drops")!, temperature: "25", description: "Moon Cloud Fast Wind", dateString: "Sunday, 8 March 2021"),
        .init(weatherImage: UIImage(named: "Thunderstorm")!, temperature: "26", description: "Pretty good weather", dateString: "Sunday, 8 March 2021")
    ]
    
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
        collectionView.dataSource = self
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
    
}

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCell.reuseIdentifier, for: indexPath) as? WeatherCell else {
            return UICollectionViewCell()
        }
        
        let viewModel = weatherData[indexPath.item]
        cell.configure(with: viewModel)
        
        return cell
    }
}

extension WeatherViewController: UICollectionViewDelegate {
    
}

