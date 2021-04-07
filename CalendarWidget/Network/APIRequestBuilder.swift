//
//  APIRequestBuilder.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 18.02.21.
//

import Foundation

protocol APIRequestBuilder {
    var urlRequest: URLRequest { get }
    var baseURL: URL { get }
    var endpointDescription: String { get }
}
