//
//  DateFormatHelper.swift
//  RxWeather
//
//  Created by Павло Сніжко on 27.05.2023.
//

import Foundation

struct DateFormatHelper {
    static let dayOfWeekFormatter: DateFormatter = {
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE, d MMMM yyyy"
        dayOfWeekFormatter.locale = Locale(identifier: "en_US")
        return dayOfWeekFormatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter
    }()
    
    static let hourlyDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter
    }()
    
    
    static func mapToDayOfWeek(from string: String) -> String {
        guard let date = DateFormatHelper.dateFormatter.date(from: string) else {
            return ""
        }

        return DateFormatHelper.dayOfWeekFormatter.string(from: date)
    }
    
    static func dateFromUTC(dt: Int) -> Date {
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        return date
    }
}
