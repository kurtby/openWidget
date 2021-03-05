//
//  CalendarExtension.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 10.02.21.
//

import Foundation

extension Calendar {
    
    // Generate days for 3 week from current date
    func days(for date: Date = Date()) -> [Date] {
        
        // Previous Week
        guard let prevWeekDate = self.date(byAdding: DateComponents(weekOfYear: -1), to: date) else {
            return []
        }
         
        let startDayOfDate = prevWeekDate.dateStart(.weekOfYear, calendar: self)
        
        // Next Week
        guard let nextWeekDate = self.date(byAdding: DateComponents(weekOfYear: 1), to: date) else {
            return []
        }
    
        let endDayOfDate = nextWeekDate.dateEnd(.weekOfYear, calendar: self)
    
        let calendarInterval = DateInterval(start: startDayOfDate, end: endDayOfDate)
       
        return self.generateDates(inside: calendarInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
    }
    
    func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates: [Date] = .init()
        dates.append(interval.start)

        enumerateDates(startingAfter: interval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }

}
