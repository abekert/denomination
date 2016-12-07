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
    
    static func fromNbrbString(date: String) -> Date? {
        return dateFromString(date: date, format: "MM/dd/yyyy")
    }
    
    private static func dateFromString(date: String, format: String) -> Date? {
        let dateFormatter = DateFormatter ()
        dateFormatter.dateFormat = format
        guard let convertedDate = dateFormatter.date(from: date) else {
            debugPrint("Can't get date from \(date) of format \(format)")
            return nil
        }
        return convertedDate
    }
    
    static func previousMonth() -> Date {
        var components = DateComponents()
        components.month = -1
        let date = NSCalendar.current.date(byAdding: components, to: Date())
        return date!
    }
}
