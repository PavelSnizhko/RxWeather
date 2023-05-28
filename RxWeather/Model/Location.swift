//
//  Location.swift
//  RxWeather
//
//  Created by Павло Сніжко on 26.05.2023.
//

import Foundation
import MapKit

struct Location {
    let latitude: Double
    let longitude: Double
}

extension CLLocationCoordinate2D {
    
    func toLocation() -> Location {
        Location(latitude: self.latitude, longitude: self.longitude)
    }
    
}
