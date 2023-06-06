//
//  CityPreviewCoordinator.swift
//  RxWeather
//
//  Created by Павло Сніжко on 06.06.2023.
//

import UIKit
import RxSwift

class CityPreviewCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let viewModel = CityViewModel()
        let vc = CityViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: vc)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        viewModel.showWeatherViewController
            .subscribe(onNext: { [weak self] vm in
                self?.showWeather(on: navigationController, viewModel: vm)
            })
            .disposed(by: disposeBag)
        
        return Observable.never()

    }
    
    @discardableResult
    private func showWeather(on navigationController: UINavigationController, viewModel: WeatherContainerViewModel) -> Observable<Void> {
        let coordinator = WeatherCoordinator(vm: viewModel, navigationController: navigationController)
        return coordinate(to: coordinator)
    }
}
