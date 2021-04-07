//
//  APIClient.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 5.04.21.
//

import Foundation

class APIClient {
    
    typealias ResultBlock = (Result<Data, Error>) -> Void
    
    let urlSession: URLSession
    
    public init(urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.urlSession = urlSession
    }
    
    public func load(builder: APIRequestBuilder, complete: @escaping ResultBlock) {
        
        EventTracker.shared.track(.init(name: .request(builder)))
       
        urlSession.dataTask(with: builder.urlRequest) { (data, response, error) in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            if let error = error {
                // Track error
                EventTracker.shared.track(.init(name: .error(builder, error: error, code: statusCode)))
                
                complete(.failure(error))
                return
            }
           
            guard let data = data, (200...299).contains(statusCode) else {
                let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)
             
                // Track error
                EventTracker.shared.track(.init(name: .error(builder, error: error, code: statusCode)))
               
                complete(.failure(error))
                return
            }
            
            if let errors = APIError.decode(data: data) , errors.contains(where: { $0.code == .unauthorized }) {
                
                let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUserAuthenticationRequired, userInfo: nil)
                
                // Track error
                EventTracker.shared.track(.init(name: .error(builder, error: error, code: statusCode)))
                
                complete(.failure(error))
            }
            else {
               complete(.success(data))
            }

        }.resume()
    }
}
