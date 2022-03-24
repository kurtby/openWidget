//
//  Error.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 31.03.21.
//

import Foundation

struct ErrorResponse: Decodable {
    let errors: [ServerError]
}

struct ServerError: Decodable {
    let message: String
    let extensions: Extension
}

struct Extension: Decodable {
    let reason: String
    let type: String
}
