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
    typealias CalendarBlock = (CalendarResponse?, Error?) -> Void
    typealias InboxBlock = (Bool, Error?) -> Void
    typealias TokenBlock = (TokenResponse?, Error?) -> Void
    
    struct ResponseData {
        var events: [Event]?
        var weather: Weather?
        var errors: [Error] = []
        var isHaveInvites: Bool = false
        
        var isNoConnection: Bool {
            if let err = errors.first as? URLError, err.code == URLError.Code.notConnectedToInternet {
                return true
            }
            
            return false
        }
    }
    
    struct TokenResponse: Decodable {
        let accessToken: String
        let expiresIn: Int
    }
    
    private var response: ResponseData = .init()
    
    public func loadData(complete: @escaping DataBlock) {
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        self.loadWeather { (weather, error) in
            
            if let weather = weather {
                self.response.weather = weather
            }
            else if let error = error {
                self.response.errors.append(error)
            }
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.loadEvents { (events, error) in
            if let events = events {
                self.response.events = events.data?.events
            }
            else if let error = error {
                self.response.errors.append(error)
            }
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.loadInbox { (isHaveInvites, error) in
            self.response.isHaveInvites = isHaveInvites
            
            if let error = error {
                self.response.errors.append(error)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
            print("DONE")
            print("ERRORS: ---->>", self.response.errors.count)
            print("Events: --->", self.response.events?.count)
            print("Is have invites: -->", self.response.isHaveInvites)
            print("Weather: ---> ", self.response.weather?.temperature)
            
            complete(self.response, self.response.errors.first)
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
                    let result = try decoder.decode(TokenResponse.self, from: data)
                    complete(result, nil)
                } catch(let error) {
                    complete(nil, error)
                }
            case .failure(let error):
                complete(nil, error)
            }
        }
    }
    
    public func loadCalendars(complete: @escaping CalendarBlock) {
        self.load(builder: APIEndpoint.calendars) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let result = try decoder.decode(CalendarResponse.self, from: data)
                    complete(result, nil)
                } catch(let error) {
                    complete(nil, error)
                }
            case .failure(let error):
                complete(nil, error)
            }
        }
    }
    
    public func loadInbox(complete: @escaping InboxBlock) {
        self.load(builder: APIEndpoint.inbox) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let result = try decoder.decode(InboxResponse.self, from: data)
                    complete(result.data.inbox.events.hasEvents, nil)
                } catch(let error) {
                    complete(false, error)
                }
                
            case .failure(let error):
                 complete(false, error)
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

extension Network {
    
    func demoEvents() -> [Event] {
        
        let event1Date = Date()
        let nextUpdateDate: Date = Calendar.current.date(byAdding: .hour, value: 1, to: event1Date) ?? event1Date
        
        let event2Date: Date = Calendar.current.date(byAdding: .hour, value: 4, to: event1Date) ?? event1Date
        let nextUpdate2Date: Date = Calendar.current.date(byAdding: .hour, value: 2, to: event2Date) ?? event2Date
        
        var edges: [Edges] = []
        
        for _ in 0...14 {
            edges.append(Edges(node: Node(user: User(email: "valent-in@list.ru"))))
        }
        
        let event = Event(uid: UUID().uuidString, title: "Обсуждение планов", from: event1Date, to: nextUpdateDate, fullDay: false, recurrenceID: nil, status: "NEEDS_ACTION", calendar: .init(uid: UUID().uuidString, title: "Personal", color: "#9EDBFF", type: "PERSONAL"), call: nil, location: .init(description: "Видеозвонки Mail.ru"), access: "", attendeesCount: 14, attendeesConnection: .init(edges: edges), organizer: .init(email: "valent-in@list.ru"))
        
        let event2 = Event(uid: UUID().uuidString, title: "Запись к стоматологу", from: event2Date, to: nextUpdate2Date, fullDay: false, recurrenceID: nil, status: "ACCEPTED", calendar: .init(uid: UUID().uuidString, title: "Personal", color: "#9EDBFF", type: "PERSONAL"), call: nil, location: .init(description: "пр. Вернадского"), access: "", attendeesCount: 0, attendeesConnection: .init(edges: []), organizer: nil)
      
        return [event, event2]
    }
    
}
