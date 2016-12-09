//
//  NSDateExtensions.swift
//  Denomination
//
//  Created by Alexander Bekert on 18/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import Foundation

extension Date {
    var shortDescription: String {
        let dateFormatter = DateFormatter ()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
    
    var shortShortDescription: String {
        let dateFormatter = DateFormatter ()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
    
    func nbrbDescription() -> String {
        let units = Set(arrayLiteral: Calendar.Component.day, Calendar.Component.month, Calendar.Component.year)
        let components = NSCalendar.current.dateComponents(units, from: self)
        return "\(components.month!)/\(components.day!)/\(components.year!)"
    }
    
    static func from(nbrbString date: String) -> Date? {
//        let format = "yyyy-MM-dd hh:mm:ss"
        let format = "yyyy-MM-dd"
        let trimmedDate = date.substring(to: date.index(date.startIndex, offsetBy: 10))
        return from(dateString: trimmedDate, withFormat: format);
//        return dateFromString(date: date, format: "yyyy-MM-dd hh:mm:ss")
    }
    
    private static func from(dateString date: String, withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter ()
        dateFormatter.dateFormat = format
        guard let convertedDate = dateFormatter.date(from: date) else {
            debugPrint("Can't get date from \(date) of format \(format)")
            return nil
        }
        return convertedDate
    }
    
    static func previousMonth() -> Date {
        return Date().previousMonth()
    }
    
    func previousMonth() -> Date {
        var components = DateComponents()
        components.month = -1
        let date = NSCalendar.current.date(byAdding: components, to: self)
        return date!
    }
    
    static func tomorrow() -> Date {
        return Date().tomorrow()
    }
    
    func tomorrow() -> Date {
        return self.addingTimeInterval(3600 * 24)
    }
}
