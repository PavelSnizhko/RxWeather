import UIKit
import RxSwift

final class WeatherCell: UICollectionViewCell {
    static let reuseIdentifier = "WeatherCell"
    
    var viewModel: WeatherCellViewModel! {
        didSet {
            setupBindings()
        }
    }
    
    private let disposeBag = DisposeBag()
    
    private let containerView: UIView = {
        let view = UIView()
        // Set container view properties, such as background color, corner radius, etc.
        return view
    }()
    
    private lazy var dateContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.bold, size: 11)
        label.numberOfLines = 1
        return label
    }()
    
    private let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        // Set weather image view properties, such as content mode, constraints, etc.
        return imageView
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.bold, size: 40)
        label.numberOfLines = 1
        label.textColor = Color.textColor.value
        // Set temperature label properties, such as text color, alignment, constraints, etc.
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NunitoSans(.bold, size: 11)
        label.textColor = Color.textColor.value
        // Set description label properties, such as text color, alignment, constraints, etc.
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBindings() {
        viewModel.weatherImage.bind(to: weatherImageView.rx.image).disposed(by: disposeBag)
        
        dateLabel.text = viewModel.dayOfWeek
        temperatureLabel.text = viewModel.celciusTemperature
        descriptionLabel.text = viewModel.description
        
    }
    
    private func setUI() {
        // Add subviews and set up constraints
        backgroundColor = .clear
        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = Color.mainPurple.value
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [weatherImageView,
                                                       temperatureLabel,
                                                       descriptionLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            weatherImageView.heightAnchor.constraint(equalToConstant: 184),
            weatherImageView.widthAnchor.constraint(equalToConstant: 184),
            temperatureLabel.heightAnchor.constraint(equalToConstant: 61)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor)
        ])
        
        dateContainerView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateContainerView)
        dateContainerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateContainerView.heightAnchor.constraint(equalToConstant: 34),
            dateContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: bounds.width - 2 * 5),
            dateContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateContainerView.topAnchor.constraint(equalTo: topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor, constant: 14),
            dateLabel.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor, constant: -14),
            dateLabel.centerYAnchor.constraint(equalTo: dateContainerView.centerYAnchor)
        ])
        
    }
}

