//
//  CurrentWeatherCell.swift
//  RxWeather
//
//  Created by Павло Сніжко on 22.05.2023.
//

import UIKit
import RxSwift

final class CurrentWeatherCell: UICollectionViewCell {
    static let reuseIdentifier = "CurrentWeatherCell"
    
    var viewModel: WeatherCellViewModel! {
        didSet {
            bindViewModel()
        }
    }
    
    private let disposeBag = DisposeBag()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.NunitoSans(.regular, size: 12)
        label.numberOfLines = 1
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.NunitoSans(.bold, size: 18)
        label.numberOfLines = 1
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        layer.cornerRadius = 25
        backgroundColor = .white
        
        // Add your UI elements to the cell's contentView and set up constraints
        let stackView = UIStackView(arrangedSubviews: [timeLabel, imageView, temperatureLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 2
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
        ])
        
    }
    
    private func bindViewModel() {
        viewModel.weatherImage.bind(to: imageView.rx.image).disposed(by: disposeBag)
        
        timeLabel.text = viewModel.dateString
        temperatureLabel.text = viewModel.celciusTemperature
    }
    
}
