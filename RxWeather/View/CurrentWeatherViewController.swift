//
//  CurrentWeatherViewController.swift
//  RxWeather
//
//  Created by Павло Сніжко on 22.05.2023.
//

import UIKit
import RxSwift

class CurrentWeatherViewController: UIViewController {
    
    var viewModel: CurrentWeatherViewModel! {
        didSet {
            setupBindings()
        }
    }
    
    private var disposeBag: DisposeBag!
    
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
        label.isHidden = true
        return label
    }()
    
    private lazy var headerView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dayLabel, nextDaysLabel])
        stackView.spacing = 0
        stackView.alignment = .center
        
        return stackView
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
        NSLayoutConstraint.activate([containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     containerView.topAnchor.constraint(equalTo: view.topAnchor),
                                     containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        collectionView.register(CurrentWeatherCell.self, forCellWithReuseIdentifier: CurrentWeatherCell.reuseIdentifier)
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
        
        view.addSubview(loaderView)
        NSLayoutConstraint.activate([
            loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupBindings() {
        disposeBag = DisposeBag {
            let output = viewModel.transform(input: .init(viewDidLoad: rx.viewDidLoad))
            
            output.wetherCellViewodels
                .bind(to: collectionView.rx.items(cellIdentifier: CurrentWeatherCell.reuseIdentifier, cellType: CurrentWeatherCell.self)) { index, viewModel, cell in
                cell.viewModel = viewModel
            }
            
            output.loadingDriver.drive(onNext: { [weak self] isLoaded in
                self?.processLoading(with: isLoaded)
            })
            
        }
    }
    
    private func processLoading(with isLoading: Bool) {
        if !isLoading {
            loaderView.stopAnimating()
        } else {
            loaderView.startAnimating()
        }
    }

}

extension CurrentWeatherViewController: UICollectionViewDelegate {
    
}
