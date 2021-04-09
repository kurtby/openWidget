//
//  ModelData.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 23.02.21.
//

import Foundation

class EventModelData {
    
    struct EventCalendar {
        let date: DateComponents
        var events: [Event]
    }
    
    private var events: [Event]
    private var userCalendars: [EventsCalendar]
    private var selectedCalendars: [CalendarType]
    
    private var headersDate: [Date] = []
    private var days: [EventCalendar] = .init()
    
    init(events: [Event], userCalendars: [EventsCalendar], selectedCalendars: [CalendarType]) {
        self.events = events
        self.userCalendars = userCalendars
        self.selectedCalendars = selectedCalendars
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
        let allowedCalendars = selectedCalendars.map({$0.identifier})
        
        // Get id of used calendars in events then check with exist in intent
        // If empty do not filter by calendars
        let calendarIDs = userCalendars.map({$0.uid})
        
        let filterCalendarIDs = calendarIDs.filter({allowedCalendars.contains($0)})
        
        if !allowedCalendars.isEmpty && !filterCalendarIDs.isEmpty {
            nextEvents = events.filter({allowedCalendars.contains($0.calendar.uid)})
        }
        
        // Group events by week day
        let groupedByDay = Dictionary(grouping: nextEvents, by: { $0.from.components })
      
        // Map and sort events
        self.days = groupedByDay.map { (date, events) -> EventCalendar in
            let sortedEvents = events.sorted(by: { ($0.orderFullday, $0.from, $0.orderPriority) < ($1.orderFullday, $1.from, $1.orderPriority) })
            return EventCalendar(date: date, events: sortedEvents)
        }
        
        // Sort days
        self.days.sort(by: {($0.date.year ?? 0, $0.date.month ?? 0, $0.date.day ?? 0) < ($1.date.year ?? 0, $1.date.month ?? 0, $1.date.day ?? 0)})

        // Flat array
        let sortedEvents = self.days.flatMap({$0.events})
        
        // Return 6 first events (more is useless)
        return sortedEvents.prefix(6).map({$0})
    }
    
}
