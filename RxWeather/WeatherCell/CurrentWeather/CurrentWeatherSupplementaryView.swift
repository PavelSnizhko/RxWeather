//
//  CurrentWeatherSupplementaryView.swift
//  RxWeather
//
//  Created by Павло Сніжко on 22.05.2023.
//

import UIKit

class WeatherSupplementaryView: UICollectionReusableView {
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.bold, size: 16)
        return label
    }()
    
    private let nextDaysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.bold, size: 16)
        return label
    }()
    
    private lazy var headerView = UIStackView(arrangedSubviews: [dayLabel, nextDaysLabel])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [dayLabel, nextDaysLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: topAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
                                     stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 30),
                                     stackView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    func configure(leftString: String, rightSring: String) {
        dayLabel.text = leftString
        dayLabel.text = rightSring
    }
}
