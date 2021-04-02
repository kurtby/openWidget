//
//  APIEndpoint.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 18.02.21.
//

import Foundation

enum APIEndpoint {
    case calendars
    case events(_ params: EventParams)
    case weather
    case inbox
    case accessToken(APITokenGrant)
}

struct EventParams {
    let from: Date
    var to: Date {
        Calendar.current.date(byAdding: DateComponents(weekOfYear: 1), to: from) ?? from
    }
}

extension APIEndpoint: APIRequestBuilder {
    
    var headers: [String: String] {
        var defaultHeaders =
        ["Accept"       : "application/json",
        "Content-Type"  : "application/json"]
        
        if let token = APITokenStorage().get()?.accessToken {
            defaultHeaders["Authorization"] = "Bearer \(token)"
        }
        
        return defaultHeaders
    }
    
    var baseURL: URL {
        switch self {
        case .weather:
            return URL(string: "https://ad.mail.ru/adi/223382")!
        case .accessToken:
            return URL(string: "https://o2.mail.ru/token")!
        default:
            return URL(string: "https://calendar.mail.ru/graphql")!
        }
    }
            
    var urlRequest: URLRequest {
        switch self {
        case .calendars:
            var request = URLRequest(url: baseURL)
            request.httpMethod = "POST"
            
            self.additionalHeaders(headers, request: &request)
            
            let parameters = [
                "operationName":"FetchCalendarsWidget",
                "query":"query FetchCalendarsWidget {calendars {uid, title, type, color } }"
            ]
            
            if let body = try? JSONSerialization.data(withJSONObject: parameters) {
                request.httpBody = body
            }
            
            return request
        case .weather:
            let request = URLRequest(url: baseURL)
            return request
        case .events(let params):
            var request = URLRequest(url: baseURL)
            request.httpMethod = "POST"
            
            self.additionalHeaders(headers, request: &request)
            
            let parameters = [
                "operationName":"FetchEventsWidget",
                "variables": ["from" : params.from.iso8601String,
                              "to" : params.to.iso8601String],
                "query":"query FetchEventsWidget($from: Time!, $to: Time!) {events(from: $from, to: $to, buildVirtual: true) {uid, title, from, to, fullDay, recurrenceID, status, calendar {uid, title, color, type }, call, organizer { email }, location { description }, access, attendeesCount, attendeesConnection(first: 5) { edges { node { user { email } } } } } }"

            ] as [String : Any]
            
            if let body = try? JSONSerialization.data(withJSONObject: parameters) {
                request.httpBody = body
            }
            
            return request
        case .inbox:
            var request = URLRequest(url: baseURL)
            request.httpMethod = "POST"
            
            self.additionalHeaders(headers, request: &request)
            
            let parameters = [
                "operationName" : "InboxWidget",
                "query" : "query InboxWidget {inbox{events {hasEvents}}}"
            ]
            
            if let body = try? JSONSerialization.data(withJSONObject: parameters) {
                request.httpBody = body
            }
            
            return request
        case .accessToken(let parameters):
            var request = URLRequest(url: baseURL)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setHTTPBody(parameters: parameters.parameters as [String: AnyObject])

            return request
        }
    }
    
}

extension APIEndpoint {
    
    fileprivate func additionalHeaders(_ additionalHeaders: [String: String]?, request: inout URLRequest) {
        
        guard let headers = additionalHeaders else { return }
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}
