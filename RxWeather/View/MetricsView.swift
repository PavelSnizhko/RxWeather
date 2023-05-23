//
//  MetricsView.swift
//  RxWeather
//
//  Created by Павло Сніжко on 22.05.2023.
//

import UIKit

class MetricsViewController: UIViewController {
    
    private let vm: MetricViewModel = MetricViewModel()
    
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
        // Set the table view's delegate and data source
        collectionView.dataSource = self
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
}

extension MetricsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.metrics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MetricCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        
        let metric = vm.metrics[indexPath.row]
        // Configure the cell with data based on the index path
        
        cell.configure(with: metric)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let metric = vm.metrics[indexPath.row]
        let width = maxLabelWidth(with: metric)
        
        return CGSize(width: width, height: 52)
    }
    
    //TODO: maybe, have to be in
    private func maxLabelWidth(with metric: Metric) -> CGFloat {
        let valueLabel = UILabel(frame: CGRect.zero)
        valueLabel.text = metric.valueString
        valueLabel.font = UIFont.NunitoSans(.bold, size: 12)
        valueLabel.sizeToFit()
        
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.text = metric.title
        titleLabel.font = UIFont.NunitoSans(.bold, size: 12)
        titleLabel.sizeToFit()
        
        return max(valueLabel.frame.width, titleLabel.frame.width)
    }
    
}
