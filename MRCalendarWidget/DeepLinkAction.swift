//
//  DeepLinkAction.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 7.04.21.
//

import Foundation

enum DeepAction: CustomStringConvertible {

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
    
    var description: String {
        switch self {
        case .openURL(let url):
            return "Open url \(url.absoluteString)"
        case .event(let event):
            return "\(event)"
        default:
            return "Unknown Action"
        }
    }
}

extension DeepAction {
    struct DeepEvent: CustomStringConvertible {
        var id: String?
        var calendarID: String?
        var status: String?
        
        init(dictionary: [String: Any]) {
            self.id = dictionary["eventID"] as? String
            self.calendarID = dictionary["calendarID"] as? String
            self.status = dictionary["status"] as? String
        }
        
        var description: String {
            return "Event: \(id ?? "") calendar: \(calendarID ?? "") , status: \(status ?? "")"
        }
    }
}

extension DeepAction {
    
    enum EvenType: CustomStringConvertible {
     
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
        
        var description: String {
            switch self {
            case .create:
                return "Create Event Pressed"
            case .reload:
                return "Reload Pressed"
            case .response(let event):
                return "Action Pressed: \(event)"
            case .open(let event):
                return "Open event: \(event)"
            case .unknown:
                return "Unknown"
            }
        }
    }

}
