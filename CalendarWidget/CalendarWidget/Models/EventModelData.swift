//
//  ModelData.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 23.02.21.
//

import Foundation

class EventModelData {
    
    public var isDateHeaderInstalled: Bool = false
    
    private var events: [Event]
    private var calendars: [CalendarType]
    
    init(events: [Event], calendars: [CalendarType]) {
        self.events = events
        self.calendars = calendars
    }
    
    public func isDateHeaderNeeded(for date: Date) -> Bool {
        if !Calendar.current.isDateInToday(date) && !self.isDateHeaderInstalled {
            self.isDateHeaderInstalled = true
            return true
        }
        return false
    }
    
    public var nextEvents: [Event] {
        var nextEvents = events
        
        // Check for calendars selected, if empty, show all calendars
        let allowedCalendars = calendars.map({$0.identifier})
        
        print("allowedCalendars", allowedCalendars)
        
        if !allowedCalendars.isEmpty {
            nextEvents = events.filter({allowedCalendars.contains($0.calendar.uid)})
        }
        
        // Sort by date
        nextEvents = nextEvents.sorted(by: {$0.from < $1.from}).prefix(5).map({$0})
        
        if !nextEvents.isEmpty {
            
            // Get personal events
            var personalFiltered = nextEvents.filter({ $0.calendar.calendarType == .personal }).sorted { $0.from < $1.from }
            
            // Get holidays events
            let holidaysFiltered = nextEvents.filter({ $0.calendar.calendarType == .holidays }).sorted { $0.from < $1.from }

            if personalFiltered.isEmpty {
                return holidaysFiltered.prefix(3).map({$0})
            }
            else {
                if personalFiltered.count == 1 {
                    personalFiltered.append(contentsOf: holidaysFiltered.prefix(2))
                    return personalFiltered
                }
                else if personalFiltered.count == 2 {
                    // Check if all events is accepted
                    if personalFiltered.allSatisfy({ $0.eventStatus == .accepted || $0.eventStatus == .maybe}) {
                        personalFiltered.append(contentsOf: holidaysFiltered.prefix(1))
                        return personalFiltered
                    }
                    else {
                        return personalFiltered
                    }
                }
                
                return personalFiltered.prefix(3).map({$0})
            }
        }
        
        return []
    }
    
}
