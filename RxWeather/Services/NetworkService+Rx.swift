//
//  WeatherService.swift
//  RxWeather
//
//  Created by Павло Сніжко on 25.05.2023.
//

import Foundation
import RxSwift
import RxCocoa
import NetworkLibrary

//MARK: - RX

extension NetworkFacade {
    
    public func execute<T: Decodable>(resource: Resource<T>) -> Observable<T> {
        return Observable.create { observer in
            execute(resource: resource) { result in
                switch result {
                case let .success(decodedModel):
                    observer.onNext(decodedModel)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
        .observe(on: MainScheduler.instance)
    }
    
    public func execute(requestMetaData: RequestMetaData) -> Observable<Data> {
        return Observable.create { observer in
            execute(requestData: requestMetaData) { result in
                switch result {
                case let .success(data):
                    observer.onNext(data)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
        .observe(on: MainScheduler.instance)
    }
    
}
