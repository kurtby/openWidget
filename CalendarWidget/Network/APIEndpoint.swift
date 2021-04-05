//
//  APIEndpoint.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 18.02.21.
//

import Foundation

enum APIEndpoint {
    case calendars
    case events(_ params: Event.RequestParameters)
    case weather
    case inbox
    case accessToken(APITokenGrant)
}

extension APIEndpoint: APIRequestBuilder {
    
    var headers: [String: String] {
        var defaultHeaders =
        ["Accept"       : "application/json",
        "Content-Type"  : "application/json"]
        
        if let token = APITokenStorage().token?.accessToken {
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
            request.additionalHeaders(headers)
            
            let parameters = [
                "operationName":"FetchCalendarsWidget",
                "query":"query FetchCalendarsWidget {calendars {uid, title, type, color } }"
            ] as [String: AnyObject]
            
            request.setHTTPBody(parameters: parameters, type: .json)
            
            return request
        case .weather:
            let request = URLRequest(url: baseURL)
            return request
        case .events(let params):
            var request = URLRequest(url: baseURL)
            request.httpMethod = "POST"
            request.additionalHeaders(headers)
            request.setHTTPBody(parameters: params.parameters, type: .json)
            
            return request
        case .inbox:
            var request = URLRequest(url: baseURL)
            request.httpMethod = "POST"
            request.additionalHeaders(headers)
            
            let parameters = [
                "operationName" : "InboxWidget",
                "query" : "query InboxWidget {inbox{events {hasEvents}}}"
            ] as [String: AnyObject]
            
            request.setHTTPBody(parameters: parameters, type: .json)
            return request
        case .accessToken(let params):
            var request = URLRequest(url: baseURL)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setHTTPBody(parameters: params.parameters, type: .query)

            return request
        }
    }
    
}
