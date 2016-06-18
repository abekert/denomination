//
//  NSDateExtensions.swift
//  Denomination
//
//  Created by Alexander Bekert on 18/06/16.
//  Copyright © 2016 Alexander Bekert. All rights reserved.
//

import Foundation

extension NSDate {
    var shortDescription: String {
        let dateFormatter = NSDateFormatter ()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        return dateFormatter.stringFromDate(self)
    }
    
    var shortShortDescription: String {
        let dateFormatter = NSDateFormatter ()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        return dateFormatter.stringFromDate(self)
    }
    
    func nbrbDescription() -> String {
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: self)
        return "\(components.month)/\(components.day)/\(components.year)"
    }
    
    class func fromNbrbString(date: String) -> NSDate? {
        return dateFromString(date, format: "MM/dd/yyyy")
    }
    
    private static func dateFromString (date: String, format: String) -> NSDate? {
        let dateFormatter = NSDateFormatter ()
        dateFormatter.dateFormat = format
        guard let convertedDate = dateFormatter.dateFromString(date) else {
            debugPrint("Can't get date from \(date) of format \(format)")
            return nil
        }
        return convertedDate
    }
    
    class func previousMonth() -> NSDate {
        let components = NSDateComponents()
        components.month = -1
        let date = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: NSDate(), options: NSCalendarOptions.MatchFirst)!
        return date
    }
}
