//
//  WeatherCoordinator.swift
//  RxWeather
//
//  Created by Павло Сніжко on 06.06.2023.
//

import UIKit
import RxSwift

class WeatherCoordinator: BaseCoordinator<Void> {
    
    private let vm: WeatherContainerViewModel
    
    private let navigationController: UINavigationController
    
    init(vm: WeatherContainerViewModel, navigationController: UINavigationController) {
        self.vm = vm
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let vc = WeatherContainerViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: false)
        
        return vc.rx.viewWillDisappear.map { _ in }
    }
}
