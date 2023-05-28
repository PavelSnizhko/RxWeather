//
//  ViewModelType.swift
//  RxWeather
//
//  Created by Павло Сніжко on 27.05.2023.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
