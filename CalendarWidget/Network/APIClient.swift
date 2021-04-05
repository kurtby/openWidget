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
        urlSession.dataTask(with: builder.urlRequest) { (data, response, error) in
            if let error = error {
                complete(.failure(error))
                return
            }
           
            guard let data = data, let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                complete(.failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)))
               return
            }
            
            if let errors = APIError.decode(data: data) , errors.contains(where: { $0.code == .unauthorized }) {
                complete(.failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorUserAuthenticationRequired, userInfo: nil)))
            }
            else {
               complete(.success(data))
            }

        }.resume()
    }
}
