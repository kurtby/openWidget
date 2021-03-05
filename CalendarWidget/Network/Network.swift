//
//  Network.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 22.02.21.
//

import Foundation
import Combine

class Network {
    
    typealias ResultBlock = (Result<Data, Error>) -> Void
    typealias DataBlock = (ResponseData, Error?) -> Void
    
    typealias WeatherBlock = (Weather?, Error?) -> Void
    typealias EventsBlock = (EventResponse?, Error?) -> Void
    typealias TokenBlock = (ResponseToken?, Error?) -> Void
    
    struct ResponseData {
        var events: [Event]?
        var weather: Weather?
    }
    
    struct ResponseToken: Decodable {
        let accessToken: String
        let expiresIn: Int
    }
    
    private var response: ResponseData = .init()
    
    public func loadData(complete: @escaping DataBlock) {
        
        self.loadWeather { (weather, error) in
            
            if let weather = weather {
                self.response.weather = weather
            }
            
            self.loadEvents { (events, error) in
                if let events = events {
                    print("Events Error", events.errors?.first?.message)
                    print("Events data:", events.data?.events)
                    self.response.events = events.data?.events
                }
            
                complete(self.response, error)
            }
        }
    }
    
    public func loadEvents(complete: @escaping EventsBlock) {
      
        func runRequest() {
            self.load(builder: APIEndpoint.events(.init(from: Date()))) { (result) in
                switch result {
                case .success(let data):
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let result = try decoder.decode(EventResponse.self, from: data)
                        complete(result, nil)
                    } catch(let error) {
                        complete(nil, error)
                    }
                case .failure(let error):
                    complete(nil, error)
                }
            }
        }
        
        if self.isTokenExistAndAlive {
            runRequest()
        }
        else {
            self.loadAccessToken { (response, error) in
                
                if let response = response , response.accessToken.count > 0  {
                    UserDefaults.appGroup.setValue(response.accessToken, forKey: UserDefaults.Keys.accessToken.rawValue)
                    
                    var expireDate = Date()
                    expireDate.addTimeInterval(TimeInterval(response.expiresIn))
                
                    UserDefaults.appGroup.setValue(expireDate, forKey: UserDefaults.Keys.accessTokenExpireDate.rawValue)
                    
                    runRequest()
                }
                else {
                    complete(nil, error)
                }
            }
        }
    }

    public func loadWeather(complete: @escaping WeatherBlock) {
        
        self.load(builder: APIEndpoint.weather) { (result) in
            switch result {
            case .success(let data):
                do {
                    let result = try JSONDecoder().decode(Weather.self, from: data)
                    complete(result, nil)
                }
                catch(let error) {
                    complete(nil, error)
                }
            case .failure(let error):
                complete(nil, error)
            }
        }
    }
    
    public func loadAccessToken(complete: @escaping TokenBlock) {
        
        guard let _ = UserDefaults.appGroup.string(forKey: UserDefaults.Keys.token.rawValue) else {
            print("NO REFRESH TOKEN GO TO MAIN TARGET APP")
            complete(nil, nil)
            return
        }
        
        self.load(builder: APIEndpoint.accessToken) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let result = try decoder.decode(ResponseToken.self, from: data)
                    complete(result, nil)
                } catch(let error) {
                    complete(nil, error)
                }
            case .failure(let error):
                complete(nil, error)
            }
        }
    }
}

extension Network {

    func load(builder: APIRequestBuilder, complete: @escaping ResultBlock)  {
        URLSession.shared.dataTask(with: builder.urlRequest) { (data, response, error) in
            DispatchQueue.main.async {
                
                if let error = error {
                    complete(.failure(error))
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    complete(.failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)))
                    return
                }
                
                complete(.success(data))
            }
        }.resume()
    }
    
}

extension Network {
    
    var isTokenExistAndAlive: Bool {
        if let expireDate = UserDefaults.appGroup.object(forKey: UserDefaults.Keys.accessTokenExpireDate.rawValue) as? Date {
            if expireDate < Date() {
                print("TOKEN EXPIRED", expireDate)
                return false
            }
            else {
                print("TOKEN GOOD", expireDate)
                return true
            }
        }
        return false
    }
    
}
