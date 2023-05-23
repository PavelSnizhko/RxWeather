//
//  CurrentWeatherViewController.swift
//  RxWeather
//
//  Created by Павло Сніжко on 22.05.2023.
//

import UIKit

class CurrentWeatherViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 92, height: 132)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = CGFloat.greatestFiniteMagnitude
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        // Set up collection view properties, such as content inset, delegate, etc.
        return collectionView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.darkerSecondaryBackground.value
        return view
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.bold, size: 16)
        label.text = "Today"
        return label
    }()
    
    private let nextDaysLabel: UILabel = {
        let label = UILabel()
        label.text = "Next 7 Days >"
        label.font = UIFont.NunitoSans(.bold, size: 16)
        return label
    }()
    
    private lazy var headerView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dayLabel, nextDaysLabel])
        stackView.spacing = 0
        stackView.alignment = .center
        
        return stackView
    }()
    
    private var weatherData: [CurrentWeatherCellViewModel] = [
        .init(weatherImage: UIImage(named: "Sun cloud mid rain")!, timeString: "06:00", temperature: "23°C"),
        .init(weatherImage: UIImage(named: "Big rain drops")!, timeString: "08:00", temperature: "26°C"),
        .init(weatherImage: UIImage(named: "Thunderstorm")!, timeString: "10:00", temperature: "28°C"),
        .init(weatherImage: UIImage(named: "Thunderstorm")!, timeString: "10:00", temperature: "28°C")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     containerView.topAnchor.constraint(equalTo: view.topAnchor),
                                     containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        collectionView.register(CurrentWeatherCell.self, forCellWithReuseIdentifier: CurrentWeatherCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 132)
        ])
        
        containerView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
                                     headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
                                     headerView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -90),])
    }
    
}

extension CurrentWeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrentWeatherCell.reuseIdentifier, for: indexPath) as? CurrentWeatherCell else {
            return UICollectionViewCell()
        }
        
        let viewModel = weatherData[indexPath.item]
        cell.configure(with: viewModel)
        
        return cell
    }
    
}

extension CurrentWeatherViewController: UICollectionViewDelegate {
    
}
