//
//  AppCoordinator.swift
//  RxWeather
//
//  Created by Павло Сніжко on 06.06.2023.
//

import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    override func start() -> Observable<Void> {
        let cityCoordinator = CityPreviewCoordinator(window: window)
        return coordinate(to: cityCoordinator)
    }
}
