//
//  MetricsViewController.swift
//  RxWeather
//
//  Created by Павло Сніжко on 22.05.2023.
//

import UIKit
import RxSwift

class MetricsViewController: UIViewController {
    
    //TODO: make private via adding init for vc
    var viewModel: MetricViewModel! {
        didSet {
            setupBindings()
        }
    }
    
    private var disposeBag: DisposeBag!
    private var cellSizes: [CGSize] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 41, height: 52)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        // Set up collection view properties, such as content inset, delegate, etc.
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setUI()
    }
    
    private func setupTableView() {
        // Register the cell class or nib file if necessary
        collectionView.register(MetricCollectionViewCell.self)
        collectionView.delegate = self
    }
    
    private func setUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        // Set up the table view and its constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 33),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -33),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupBindings() {
        disposeBag = DisposeBag {
            let wetherCellViewodels = viewModel.transform(input: .init(viewDidLoad: rx.viewDidLoad)).wetherCellViewodels
            
            wetherCellViewodels.bind(to: collectionView.rx.items(cellIdentifier: MetricCollectionViewCell.defaultReuseIdentifier, cellType: MetricCollectionViewCell.self)) {[weak self] index, viewModel, cell in
                    cell.viewModel = viewModel
                    self?.cellSizes.append(viewModel.cellSize)
                }
            
            wetherCellViewodels.subscribe(onNext: { [weak self] items in
                items.forEach { vm in
                    self?.cellSizes.append(vm.cellSize)
                }
            })
        }
    }
}

extension MetricsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSizes[indexPath.row]
    }
    
}
