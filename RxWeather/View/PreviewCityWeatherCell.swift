//
//  PreviewCityWeatherCell.swift
//  RxWeather
//
//  Created by Павло Сніжко on 01.06.2023.
//

import UIKit

final class PreviewCityWeatherCell: UITableViewCell, ReusableView {
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.NunitoSans(.bold, size: 18)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.regular, size: 20)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.regular, size: 18)
        label.textColor = .darkGray
        return label
    }()
    
    var viewModel: PreviewCityWeatherViewModel! {
        didSet {
            setupBindings()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = Color.secondaryForegroundColor.value
        
        addSubview(temperatureLabel)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            temperatureLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            temperatureLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: temperatureLabel.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    private func setupBindings() {
        temperatureLabel.text = viewModel.weatherCellViewModel.celciusTemperature
        descriptionLabel.text = viewModel.weatherCellViewModel.description
        titleLabel.text = viewModel.cityName
    }
    
}
