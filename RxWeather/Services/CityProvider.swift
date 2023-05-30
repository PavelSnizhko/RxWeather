//
//  CityProvider.swift
//  RxWeather
//
//  Created by Павло Сніжко on 30.05.2023.
//

import Foundation
import NetworkLibrary
import RxSwift

class CityProvider {
    private lazy var networkManager = NetworkFacade()

    func fetchCityList() -> Observable<Cities> {
        let endpoint = "https://raw.githubusercontent.com/PavelSnizhko/CitiesList/main/cities.json"
        let requestMetaData = RequestMetaData(endpoint: endpoint, method: .get)
        let resource = Resource(requestMetaData: requestMetaData, decodingType: Cities.self)
        
        return networkManager.execute(resource: resource)
    }
}
