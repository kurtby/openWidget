//
//  APIError.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 18.02.21.
//

import Foundation

enum APIError: Error {
    case error(Error)
    case decodingError(Error)
    case httpError(Int)
    case unknown
}
