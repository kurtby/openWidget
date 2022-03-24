//
//  DateExtension.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 10.02.21.
//

import Foundation

extension Date {
    
    var shortDateString: String {
        DateFormatter.format(self, format: "d")
    }
        
    var components: DateComponents {
        Calendar.current.dateComponents(Set(arrayLiteral: .day, .month, .year), from: self)
    }
    
    var timeString: String {
        DateFormatter.format(self, format: "HH:mm")
    }
    
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
  
}

extension Date {
    
    func dateStart(_ unit: NSCalendar.Unit, calendar: Calendar) -> Date {
        var start: NSDate?
        var interval: TimeInterval = 0
        
        guard (calendar as NSCalendar).range(of: unit , start: &start, interval: &interval, for: self), let startDate = start else {
            return Date()
        }
        
        return startDate as Date
    }
    
    func dateEnd(_ unit: NSCalendar.Unit, calendar: Calendar) -> Date {
        var start: NSDate?
        var interval: TimeInterval = 0
        
        guard (calendar as NSCalendar).range(of: unit, start: &start, interval: &interval, for: self), let startDate = start else {
            return Date()
        }
        
        let startOfNextUnit = startDate.addingTimeInterval(interval)
        let endOfThisUnit = Date(timeInterval: -0.001, since: startOfNextUnit as Date)
        return endOfThisUnit
    }
    
    func isBetween(_ date1: Date, date2: Date) -> Bool {
        (min(date1, date2) ... max(date1, date2)) ~= self
    }
    
}
