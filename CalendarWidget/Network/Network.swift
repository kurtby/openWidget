//
//  Network.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 22.02.21.
//

import Foundation

private extension Log.Categories {
    static let network: Self = "Widget.Calendar.Network"
}

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
    
    private let serialQueue = DispatchQueue(label: "widgetkit.network.serial.queue")
    private let logger = Log.createLogger(category: .network)
    
    public func loadData(_ parameters: Event.RequestParameters, complete: @escaping DataBlock) {
        if self.isLoading { return }
        
        self.response = ResponseData()
        self.completeBlock = complete
        self.isLoading = true
      
        if !self.tokenManager.isAccessTokenExist {
            self.tokenManager.requestAccessToken { (result) in
                self.isLoading = false
                
                switch result {
                case .success(_):
                    self.loadData(parameters, complete: self.completeBlock)
                case .failure(let error):
                    complete(self.response, error)
                }
            }
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        self.loadWeather { (weather, error) in
            self.serialQueue.async {
                if let weather = weather {
                    self.response.weather = weather
                }
                else if let error = error {
                    self.response.errors.append(error)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        self.loadEvents(params: parameters) { (events, error) in
            self.serialQueue.async {
                if let events = events {
                    self.response.events = events.data?.events
                }
                else if let error = error {
                    self.response.errors.append(error)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        self.loadInbox { (isHaveInvites, error) in
            self.serialQueue.async {
                self.response.isHaveInvites = isHaveInvites
                
                if let error = error {
                    self.response.errors.append(error)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        self.loadCalendars { (calendars, error) in
            self.serialQueue.async {
                self.response.calendars = calendars?.data.calendars
                
                if let error = error {
                    self.response.errors.append(error)
                }
                
                dispatchGroup.leave()
            }
        }
               
        dispatchGroup.notifyWait(target: .main, timeout: .now() + 15) {
            if self.isLoading {
                self.isLoading = false
            }
            
            self.logger.log(level: .debug, "All tasks done")
            self.logger.log(level: .debug, "Errors count: \(self.response.errors.count)")
            self.logger.log(level: .debug, "Events count: \(self.response.events?.count ?? 0)")
            self.logger.log(level: .debug, "Calendars count: \(self.response.calendars?.count ?? 0)")
            self.logger.log(level: .debug, "Is hava invites: \(self.response.isHaveInvites)")
            self.logger.log(level: .debug, "Weather: \(self.response.weather?.temperature ?? "Empty")")
          
            if self.response.isNeedAuth {
                self.tokenManager.requestAccessToken { (result) in
                    switch result {
                    case .success(_):
                        self.loadData(parameters, complete: self.completeBlock)
                    case .failure(_):
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
