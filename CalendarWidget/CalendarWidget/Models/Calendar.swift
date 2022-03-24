//
//  Calendar.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 8.03.21.
//

import Foundation

struct CalendarResponse: Decodable {
    let data: Calendars
}

struct Calendars: Decodable {
    let calendars: [EventsCalendar]
}

struct EventsCalendar: Decodable {
    let uid: String
    let title: String
    let type: String
    let color: String
}
