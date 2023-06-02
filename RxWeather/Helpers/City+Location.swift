//
//  City+Location.swift
//  RxWeather
//
//  Created by Павло Сніжко on 01.06.2023.
//

import Foundation

extension City {
    var location: Location? {
        guard let stringLatitude = self.lat,
              let stringLongitude = self.lng,
              let latitude = Double(stringLatitude),
              let longitude = Double(stringLongitude) else {
            return nil
        }
        return Location(latitude: latitude, longitude: longitude)
    }
}
