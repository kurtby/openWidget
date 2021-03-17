//
//  Constants.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 10.02.21.
//

import Foundation

struct Constants {
   
    struct DeepLink {
        static let prefix = "widget-deeplink://"
    }

    enum WidgetKind: String, CaseIterable {
        case calendarWidget = "CalendarWidget"
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
        case url(_ url: String)
         
        var urlSceme: String {
            switch self {
            case .event(let response, let eventID, let calendarID):
                return prefix + "?action=event&type=response&status=\(response.rawValue)&eventID=\(eventID)&calendarID=\(calendarID)"
            case .openEvent(let eventID, let calendarID):
                return prefix + "?action=event&type=open&eventID=\(eventID)&calendarID=\(calendarID)"
            case .create:
               return prefix + "?action=event&type=create"
            case .url(let url):
                return prefix + "?action=openURL&url=\(url)"
            }
        }
    }

}
