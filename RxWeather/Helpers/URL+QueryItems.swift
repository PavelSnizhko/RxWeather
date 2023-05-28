//
//  URL+QueryItems.swift
//  RxWeather
//
//  Created by Павло Сніжко on 26.05.2023.
//

import Foundation

/// Add quety items to request
extension URL {
    
    mutating func appendQueryItem(name: String, value: String?) {
        
        guard var urlComponents = URLComponents(string: absoluteString) else { return }
        
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        let queryItem = URLQueryItem(name: name, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return
        }
        
        self = url
    }
}
