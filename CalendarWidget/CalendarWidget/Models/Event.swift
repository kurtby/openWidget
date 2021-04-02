//
//  Event.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 18.02.21.
//

import Foundation

struct EventResponse: Decodable {
    let data: Events?
    let errors: [ServerError]?
}

struct Events: Decodable {
    let events: [Event]
}

struct Event: Decodable {
    
    enum Status {
        case needAction
        case accepted
        case maybe
        case unknow
    }
    
    let uid, title: String
    let from, to: Date
    let fullDay: Bool
    let recurrenceID: Date?
    let status: String
    let calendar: EventCalendar
    let call: String?
    let location: Location?
    let access: String
    let attendeesCount: Int
    let attendeesConnection: AttendeesConnection
    let organizer: User?
    
    // Maybe move to init
    var eventStatus: Status {
        switch self.status.uppercased() {
        case "NEEDS_ACTION":
            return .needAction
        case "ACCEPTED":
            return .accepted
        case "TENTATIVE":
            return .maybe
        default:
            return .unknow
        }
    }
    
    // For order in list (lower on top)
    var orderPriority: Int {
         if self.calendar.calendarType == .personal {
            return 0
        }
        else if self.calendar.isBirthday {
            return 1
        }
        
        return 2
    }
    
    var orderFullday: Int {
        self.fullDay ? 1 : 0
    }
}

struct EventCalendar: Decodable {
    
    enum CalendarType {
        case personal
        case holidays
        case unknow
    }
    
    let uid: String
    let title: String
    let color: String
    let type: String
    
    // Maybe move to init
    var calendarType: CalendarType {
        switch self.type.uppercased() {
        case "PERSONAL":
            return .personal
        case "HOLIDAYS":
            return .holidays
        default:
            return .unknow
        }
    }
    
    var isBirthday: Bool {
        if uid == "birthdays" {
            return true
        }
        return false
    }
    
}

struct Location: Decodable {
    let description: String
}
            
struct AttendeesConnection: Decodable {
    let edges: [Edges]
}

struct Edges: Decodable {
    let node: Node
}

struct Node: Decodable {
    let user: User
}

struct User: Decodable {
    let email: String
    
    var imageURL: String {
        return "https://filin.mail.ru/pic?email=\(email)&width=60px&height=60px"
    }
}
