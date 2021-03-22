//
//  Constants.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 10.02.21.
//

import Foundation

struct Constants {
    
    struct Timing {
        static let updateInterval: Int = 15
        static let callOffsetInterval: Int = -10
    }
     
    struct DeepLink {
        static let prefix = "widget-deeplink://"
    }

    enum WidgetKind: String, CaseIterable {
        case calendarWidget = "CalendarWidget"
    }
    
    enum LocalizablePluralKey: String {
        case event = "event count"
    }

}

extension Constants.WidgetKind {
    
    var displayName: String {
        switch self {
        case .calendarWidget:
            return "Mail.ru виджет"
        }
    }
    
    var description: String {
        switch self {
        case .calendarWidget:
            return "Календарь, Погода, События"
        }
    }
    
}

extension Constants.DeepLink {
    
    enum EventResponse: String {
        case yes = "ACCEPTED"
        case no = "DECLINED"
        case maybe = "TENTATIVE"
    }

    enum Event {
        case event(EventResponse, eventID: String, calendarID: String)
        case openEvent(eventID: String, calendarID: String)
        case create
        case inbox
        case calendar
        case url(_ url: String)
         
        var url: String {
            switch self {
            case .event(let response, let eventID, let calendarID):
                return prefix + "?action=event&type=response&status=\(response.rawValue)&eventID=\(eventID)&calendarID=\(calendarID)"
            case .openEvent(let eventID, let calendarID):
                return prefix + "?action=event&type=open&eventID=\(eventID)&calendarID=\(calendarID)"
            case .create:
               return prefix + "?action=event&type=create"
            case .inbox:
                return Event.url("https://touch.calendar.mail.ru/inbox").url
            case .calendar:
                return Event.url("https://touch.calendar.mail.ru").url
            case .url(let url):
                return prefix + "?action=openURL&url=\(url)"
            }
        }
    }

}
