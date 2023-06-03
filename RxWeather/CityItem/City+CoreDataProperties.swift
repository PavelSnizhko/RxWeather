//
//  City+CoreDataProperties.swift
//  RxWeather
//
//  Created by Павло Сніжко on 03.06.2023.
//
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var country: String?
    @NSManaged public var lat: String?
    @NSManaged public var lng: String?
    @NSManaged public var name: String?
    @NSManaged public var isSelected: Bool

}

extension City : Identifiable {

}
