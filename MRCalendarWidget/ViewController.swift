//
//  ViewController.swift
//  MRCalendarWidget
//
//  Created by Aleksandr Karimov on 01.02.2021.
//

import UIKit
import WidgetKit

/**
Ниже вы можете найти примеры работы с API:
* получение календарного access token'а при помощи refresh token'а
* получение списка календарей

Итоговая схема работы должна выглядеть так:
* этот таргет получает refresh token и сохранять его в shared user defaults (нужно будет создать app group)
* таргет виджета при помощи refresh token'а получает access token и делает все необходимые запросы в календарный API

*/

class ViewController: UIViewController  {
     
    @IBOutlet private weak var calendarLabel: UILabel!
    
    @IBOutlet private weak var tokenTextField: UITextField!


    var refreshToken: String? {
        get {
            UserDefaults.appGroup.string(forKey: UserDefaults.Keys.token.rawValue)
        }
        set {
            // Reset accessToken in widget too
            UserDefaults.appGroup.set(nil, forKey: UserDefaults.Keys.accessTokenExpireDate.rawValue)
            UserDefaults.appGroup.set(newValue, forKey: UserDefaults.Keys.token.rawValue)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let sdk = MRMailSDK.sharedInstance()
        sdk.delegate   = self;
        sdk.uiDelegate = self;
    }


    @IBAction private func updateTokenButtonPressed(_ sender: UIButton) {
        let sdk = MRMailSDK.sharedInstance()
        sdk.forceLogout()
        sdk.authorize()
        
        calendarLabel.text = ""
        
    }
    
    @IBAction private func reloadWidgeButtonDidPressed(_ sender: UIButton) {
        WidgetCenter.shared.reloadAllTimelines()
    }

    @IBAction private func requestCalendarsButtonPressed(_ sender: UIButton) {
        guard let token = refreshToken else {
            calendarLabel.text = "Получите вначале refresh token!!!"
            return
        }
        retrieveAccessToken(refreshToken: token) { (accessToken) in
            if let token = accessToken {
                
                self.requestCalendars(accessToken: token) { (calendars) in
                    if let calendars = calendars {
                        self.calendarLabel.text = calendars.reduce("", { (str, calendar) -> String in
                            "|\(calendar.title)|" + str
                        })
                    }
                    else {
                        self.calendarLabel.text = "Не удалось получить список календарей!!!"
                    }
                }
            }
            else {
                self.calendarLabel.text = "Не удалось получить access token!!!"
            }
        }
    }
}

extension ViewController: MRMailSDKUIDelegate {
    func mrMailSDK(_ sdk: MRMailSDK, shouldPresent controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }
}

extension ViewController: MRMailSDKDelegate {
    func mrMailSDK(_ sdk: MRMailSDK, authorizationDidFinishWith result: MRSDKAuthorizationResult) {
        if let token = result.refreshToken {
            refreshToken = token
            self.tokenTextField.text = token
            WidgetCenter.shared.reloadAllTimelines()
        }
        else {
            logErrorMessage("Empty refresh token")
        }
    }

    func mrMailSDK(_ sdk: MRMailSDK, authorizationDidFailWithError error: Error) {
        logErrorMessage("Can't retrive refresh token - " + error.localizedDescription)
    }
}

fileprivate extension ViewController {

    func logErrorMessage(_ message: String) {
        print("|Error|: \(message)!!!!")
    }

    func retrieveAccessToken(refreshToken: String, completion: @escaping (String?) -> Void) {

        struct Response: Decodable {
            let accessToken: String
            let expiresIn: Int
        }

        let parameters = [
            "client_id": "685d470d9fdc4dd9be87e784f328e5e9",
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        sendPostRequest(
            urlString: "https://o2.mail.ru/token",
            getParameters: nil,
            postParameters: parameters) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let result = try? decoder.decode(Response.self, from: data) {
                    completion(result.accessToken)
                }
                else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }

    struct Calendar: Decodable {
        let uid: String
        let title: String
        let type: String
        let color: String
    }

    func requestCalendars(accessToken: String, completion: @escaping ([Calendar]?) -> Void) {

        struct Response: Decodable {
            let data: Calendars
        }

        struct Calendars: Decodable {
            let calendars: [Calendar]
        }

        let headers = [
            "Authorization" : "Bearer \(accessToken)",
            "Accept"        : "application/json",
            "Content-Type"  : "application/json"
        ]

        let parameters = [
            "operationName":"FetchCalendarsWidget",
            "query":"query FetchCalendarsWidget {calendars {uid, title, type, color } }"
        ]
        
    
        
        sendPostRequest(
            urlString: "https://calendar.mail.ru/graphql",
            additionalHeaders: headers,
            jsonParameters: parameters) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let result = try? decoder.decode(Response.self, from: data) {
                    completion(result.data.calendars)
                }
                else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    struct Event: Decodable {
        let uid, title: String
        let from, to: Date
        let fullDay: Bool
        let recurrenceID: Date?
        let status: String
        let calendar: Calendar
        let call: String?
        let access: String
        let attendeesCount: Int
     //   let attendeesConnection: AttendeesConnection
    }

    
    func requestEvents(accessToken: String, completion: @escaping ([Event]?) -> Void) {
        struct Response: Decodable {
            let data: Events
        }

        struct Events: Decodable {
            let events: [Event]
        }

        let headers = [
            "Authorization" : "Bearer \(accessToken)",
            "Accept"        : "application/json",
            "Content-Type"  : "application/json"
        ]

        let parameters = [
            "operationName":"FetchEventsWidget",
            "variables": ["from" : "2021-02-18T00:00:00.000Z",
                             "to":"2021-02-18T23:59:00.000Z"],
            "query":"query FetchEventsWidget($from: Time!, $to: Time!) {events(from: $from, to: $to, buildVirtual: true) {uid, title, from, to, fullDay, recurrenceID, status, calendar {uid, color, type }, call, access, attendeesCount, attendeesConnection(first: 5) { edges { node { user { email } } } } } }"

        ] as [String : Any]
        
        
        sendPostRequest(
            urlString: "https://calendar.mail.ru/graphql",
            additionalHeaders: headers,
            jsonParameters: parameters) { (result) in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let result = try? decoder.decode(Response.self, from: data) {
                    completion(result.data.events)
                }
                else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    

    func sendPostRequest(
        urlString: String,
        getParameters: [String: Any]?,
        postParameters: [String: Any]?,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = getParameters?.map({ (key, value) in
            URLQueryItem(name: key, value: value as? String)
        })
        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        var postUrlComponents = URLComponents()
        postUrlComponents.queryItems = postParameters?.map({ (key, value) in
            URLQueryItem(name: key, value: value as? String)
        })
        if let query = postUrlComponents.url?.query {
            request.httpBody = Data(query.utf8)
        }
        let internalCompletion: (Result<Data, Error>) -> Void = { (result) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                    error == nil else {
                internalCompletion(.failure(error ?? NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)))
                return
            }
            guard (200 ... 299) ~= response.statusCode else {
                print("response = \(response)")
                internalCompletion(.failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)))
                return
            }
            internalCompletion(.success(data))
        }
        task.resume()
    }

    func sendPostRequest(
        urlString: String,
        additionalHeaders: [String: String]?,
        jsonParameters: [String: Any]?,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        additionalHeaders?.forEach({ (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        })


        if  let json = jsonParameters,
            let body = try? JSONSerialization.data(withJSONObject: json) {
            request.httpBody = body
        }

        let internalCompletion: (Result<Data, Error>) -> Void = { (result) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                    error == nil else {
                internalCompletion(.failure(error ?? NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)))
                return
            }
            guard (200 ... 299) ~= response.statusCode else {
                print("response = \(response)")
                internalCompletion(.failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: nil)))
                return
            }
            internalCompletion(.success(data))
        }
        task.resume()
    }
}

