//
//  APIToken.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 31.03.21.
//

import Foundation

class APIToken {
    
    typealias TokenBlock = (TokenResponse?, Error?) -> Void
    
    struct TokenResponse: Decodable {
        let accessToken: String
        let expiresIn: Int
    }
    
    public let accessToken: String
    
    public let expiresAt: Date?
    
    public let refreshToken: String?
    
    public init(accessToken: String, expiresAt: Date? = nil, refreshToken: String? = nil) {
        self.accessToken = accessToken
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
    }

}
    
extension APIToken {
    
    public class func convert(_ response: TokenResponse) -> APIToken? {
        var expireDate = Date()
        expireDate.addTimeInterval(TimeInterval(response.expiresIn))
        
        return APIToken(accessToken: response.accessToken, expiresAt: expireDate, refreshToken:  Defaults.get(.refreshToken) as? String)
    }
    
    public class func decode(data: Data) -> APIToken? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let result = try decoder.decode(TokenResponse.self, from: data)
            return convert(result)
        } catch {
            return nil
        }
        
    }
}
