//
//  Network.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 22.02.21.
//

import Foundation

class Network {
    
    typealias DataBlock = (ResponseData, Error?) -> Void
    
    typealias WeatherBlock = (Weather?, Error?) -> Void
    typealias EventsBlock = (EventResponse?, Error?) -> Void
    typealias CalendarBlock = (CalendarResponse?, Error?) -> Void
    typealias InboxBlock = (Bool, Error?) -> Void
    
    private let apiClient: APIClient = APIClient()
    private let tokenManager: APITokenManager = APITokenManager(maxRetryCount: 5)
    
    private var isLoading: Bool = false
        
    private var response: ResponseData = ResponseData()
    
    private var completeBlock: DataBlock = { _,_  in }
    
    public func loadData(complete: @escaping DataBlock) {
        if self.isLoading { return }
        
        self.response = ResponseData()
        self.completeBlock = complete
        self.isLoading = true
        
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
        self.loadEvents(params: .init(from: Date())) { (events, error) in
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
               
        dispatchGroup.notifyWait(target: .main, timeout: .now() + 15) {
            if self.isLoading {
                self.isLoading = false
            }
            
            print("DONE", self.isLoading)
            print("ERRORS: ---->>", self.response.errors.count)
            print("Events: --->", self.response.events?.count)
            print("Is have invites: -->", self.response.isHaveInvites)
            print("Weather: ---> ", self.response.weather?.temperature)
            
            if self.response.isNeedAuth {
                self.tokenManager.requestAccessToken { (_, error) in
                    if error == nil {
                        self.isLoading = false
                        self.loadData(complete: self.completeBlock)
                    }
                    else {
                        complete(self.response, self.response.errors.first)
                    }
                }
            }
            else {
                complete(self.response, self.response.errors.first)
            }
        }
        
    }

    public func loadEvents(params: Event.RequestParameters, complete: @escaping EventsBlock) {
        apiClient.load(builder: APIEndpoint.events(params)) { (result) in
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

    public func loadWeather(complete: @escaping WeatherBlock) {
        apiClient.load(builder: APIEndpoint.weather) { (result) in
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
    
    public func loadCalendars(complete: @escaping CalendarBlock) {
        apiClient.load(builder: APIEndpoint.calendars) { (result) in
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
        apiClient.load(builder: APIEndpoint.inbox) { (result) in
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
