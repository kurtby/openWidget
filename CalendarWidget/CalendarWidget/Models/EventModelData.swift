//
//  ModelData.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 23.02.21.
//

import Foundation

class EventModelData {
    
    public var events: [Event]
    private var calendars: [CalendarType]
    
    private var headersDate: [Date] = []
    
    init(events: [Event], calendars: [CalendarType]) {
        self.events = events
        self.calendars = calendars
    }
    
    public func isDateHeaderNeeded(for date: Date) -> Bool {
        let isContainDate: Bool = headersDate.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) })
        
        if !Calendar.current.isDateInToday(date) && !isContainDate && date > Date() {
            headersDate.append(date)
            return true
        }
        return false
    }
    
    public var nextEvents: [Event] {
        var nextEvents = events
        
        // Check for calendars selected, if empty, show all calendars
        let allowedCalendars = calendars.map({$0.identifier})
        
        if !allowedCalendars.isEmpty {
            nextEvents = events.filter({allowedCalendars.contains($0.calendar.uid)})
        }
        
        // Sort by date
        nextEvents = nextEvents.sorted(by: {$0.from < $1.from}).prefix(5).map({$0})
        
        return nextEvents
    }
    
}
