//
//  City+CoreDataClass.swift
//  RxWeather
//
//  Created by Павло Сніжко on 30.05.2023.
//
//

import Foundation
import CoreData
import UIKit

@objc(City)
public class City: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case country, name, lat, lng
    }

    // MARK: - Codable
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            print(decoder.userInfo)
          throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        lat = try container.decodeIfPresent(String.self, forKey: .lat)
        lng = try container.decodeIfPresent(String.self, forKey: .lng)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(lat, forKey: .lat)
        try container.encodeIfPresent(lng, forKey: .lng)
    }

}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}
