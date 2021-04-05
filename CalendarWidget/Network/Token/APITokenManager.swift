//
//  APITokenStore.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 31.03.21.
//

import Foundation

class APITokenManager {
    
    public let storage: APITokenStorage = APITokenStorage()
    
    public let maxRetryCount: Int
    
    private var retryCount: Int = 0
    
    init(maxRetryCount: Int = 5) {
        self.maxRetryCount = maxRetryCount
        self.checkToken()
    }
    
    private func checkToken() {
        guard let token = storage.get(), let appRefreshToken = Defaults.get(.refreshToken) as? String else {
            return
        }
        
        if token.refreshToken != appRefreshToken {
            storage.clear()
        }
    }
    
}

extension APITokenManager {
    
    typealias TokenBlock = (TokenResponse?, Error?) -> Void
    
    struct TokenResponse: Decodable {
        let accessToken: String
        let expiresIn: Int
    }
    
    public func requestAccessToken(complete: @escaping TokenBlock) {
        guard let token = Defaults.get(.refreshToken) as? String else {
            complete(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil))
            return
        }
        
        if retryCount == maxRetryCount {
            complete(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil))
            return
        }
        
        self.retryCount += 1
    
        APIClient().load(builder: APIEndpoint.accessToken(APITokenGrant.refreshToken(token))) { (result) in
            switch result {
            case .success(let data):
                if let token = APIToken.decode(data: data) {
                    self.storage.save(token)
                }
                complete(nil, nil)
            case .failure(let error):
                complete(nil, error)
            }
        }
        
    }
}
