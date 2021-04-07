//
//  Event+RequestParams.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 5.04.21.
//

import Foundation

extension Event {
    
    struct RequestParameters: CustomStringConvertible {
        let from: Date
        var to: Date {
            Calendar.current.date(byAdding: .weekOfYear, value: 1, to: from) ?? from
        }
        
        public var parameters: [String: AnyObject] {
            [
                "operationName":"FetchEventsWidget",
                "variables": ["from" : self.from.iso8601String,
                              "to" : self.to.iso8601String],
                "query":"query FetchEventsWidget($from: Time!, $to: Time!) {events(from: $from, to: $to, buildVirtual: true) {uid, title, from, to, fullDay, recurrenceID, status, calendar {uid, title, color, type }, call, organizer { email }, location { description }, access, attendeesCount, attendeesConnection(first: 5) { edges { node { user { email } } } } } }"
            ] as [String: AnyObject]
        }
        
        var description: String {
            return "From: \(from) to: \(to)"
        }
    
    }

}
