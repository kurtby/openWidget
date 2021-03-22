//
//  ModelData.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 23.02.21.
//

import Foundation

class EventModelData {
    
    struct EventCalendar {
        let day: Int
        var events: [Event]
    }
    
    private var events: [Event]
    private var calendars: [CalendarType]
    
    private var headersDate: [Date] = []
    private var days: [EventCalendar] = .init()
    
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
      
        // Group events by week day
        let groupedByDay = Dictionary(grouping: nextEvents, by: { Int($0.from.shortDateString) ?? 0 })
      
        // Map and sort events
        self.days = groupedByDay.map { (day, events) -> EventCalendar in
            let sortedEvents = events.sorted(by: { ($0.orderFullday, $0.from, $0.orderPriority) < ($1.orderFullday, $1.from, $1.orderPriority) })
            return EventCalendar(day: day, events: sortedEvents)
        }
        
        // Sort days
        self.days.sort(by: {$0.day < $1.day})

        // Flat array
        let sortedEvents = self.days.flatMap({$0.events})
        
        // Return 6 first events (more is useless)
        return sortedEvents.prefix(6).map({$0})
    }
    
}
