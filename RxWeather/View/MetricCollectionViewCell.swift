//
//  MetricCollectionViewCell.swift
//  RxWeather
//
//  Created by Павло Сніжко on 22.05.2023.
//

import UIKit

class MetricCollectionViewCell: UICollectionViewCell, ReusableView {
    static let reuseIdentifier = "MetricTableViewCell"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // Additional setup for the icon image view
        return imageView
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.bold, size: 12)
        
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.bold, size: 9)
//        label.textColor = Color.secondaryForegroundColor.value
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setUI() {
        // Set up the cell's UI elements and constraints
        let stackView = UIStackView(arrangedSubviews: [iconImageView, valueLabel, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            iconImageView.widthAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // Configure the cell with the view model
    func configure(with metric: Metric) {
        iconImageView.image = metric.icon
        valueLabel.text = metric.valueString
        titleLabel.text = metric.title
    }
}
