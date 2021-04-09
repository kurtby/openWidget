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
    
    public var isAccessTokenExist: Bool {
        guard let token = self.storage.token, token.accessToken.count > 0 else {
            return false
        }
        
        return true
    }
    
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
    
    func resetRetryCount() {
        self.retryCount = 0
    }

}

extension APITokenManager {
    
    typealias ResponseBlock = (Result<Data, Error>) -> Void
    
    public func requestAccessToken(complete: @escaping ResponseBlock) {
        guard let token = Defaults.get(.refreshToken) as? String else {
            complete(.failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)))
            return
        }
        
        if retryCount == maxRetryCount {
            complete(.failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)))
            return
        }
        
        self.retryCount += 1
    
        APIClient().load(builder: APIEndpoint.accessToken(APITokenGrant.refreshToken(token))) { (result) in
            switch result {
            case .success(let data):
                if let token = APIToken.decode(data: data) {
                    self.storage.save(token)
                    self.resetRetryCount()
                }
                complete(.success(data))
            case .failure(let error):
                self.resetRetryCount()
                complete(.failure(error))
            }
        }
        
    }
}
