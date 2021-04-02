//
//  APIError.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 18.02.21.
//

import Foundation

public class APIError {
    
    public let code: APIErrorCode
    public let message: String?

    public init(code: APIErrorCode, message: String? = nil) {
        self.code = code
        self.message = message
    }
}

public enum APIErrorCode: String, Equatable {
    case unauthorized = "unauthorized"
}

extension APIErrorCode {
    static func decode(errors: [ServerError]) -> [APIErrorCode]? {
        errors.compactMap { $0.extensions.type }.compactMap { code in
            APIErrorCode(rawValue: code)
        }
    }
}

extension APIError {
   
    public class func decode(data: Data) -> [APIError]? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let result = try decoder.decode(ErrorResponse.self, from: data)
            return APIErrorCode.decode(errors: result.errors)?.compactMap { APIError(code: $0) }
        }
        catch {
            return []
        }
    }
    
}
