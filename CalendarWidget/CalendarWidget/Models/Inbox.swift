//
//  Inbox.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 16.03.21.
//

import Foundation

struct InboxResponse: Decodable {
    let data: Inbox
    
    struct Inbox: Decodable {
        let inbox: Events
    }
    
    struct Events: Decodable {
        let events: HasEvents
    }
    
    struct HasEvents: Decodable {
        let hasEvents: Bool
    }
}
