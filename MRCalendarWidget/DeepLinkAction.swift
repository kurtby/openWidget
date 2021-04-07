//
//  DeepLinkAction.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 7.04.21.
//

import Foundation

enum DeepAction {
    case openURL(url: URL)
    case event(type: EvenType)
    case unknown
    
    init(queryParams: [String: Any]) {
        guard let action = queryParams["action"] as? String else {
            self = .unknown
            return
        }
        
        switch action {
        case "openURL" :
            if let urlString = queryParams["url"] as? String , let url = URL(string: urlString) {
                self = .openURL(url: url)
            }
            else {
                self = .unknown
            }
        case "event":
            self = .event(type: EvenType(queryParams: queryParams))
        default:
            self = .unknown
        }
    }
}

extension DeepAction {
    struct DeepEvent {
        var id: String?
        var calendarID: String?
        var status: String?
        
        init(dictionary: [String: Any]) {
            self.id = dictionary["eventID"] as? String
            self.calendarID = dictionary["calendarID"] as? String
            self.status = dictionary["status"] as? String
        }
    }
}

extension DeepAction {
    
    enum EvenType {
        case create
        case reload
        case response(DeepEvent)
        case open(DeepEvent)
        case unknown
        
        init(queryParams: [String: Any]) {
            
            guard let type = queryParams["type"] as? String else {
                self = .unknown
                return
            }
            
            switch type {
            case "create":
                self = .create
            case "reload":
                self = .reload
            case "response":
                self = .response(DeepEvent(dictionary: queryParams))
            case "open":
                self = .open(DeepEvent(dictionary: queryParams))
            default:
                self = .unknown
            }
        }
    }

}
