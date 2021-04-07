//
//  SceneDelegate.swift
//  MRCalendarWidget
//
//  Created by Aleksandr Karimov on 01.02.2021.
//

import UIKit
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var deepLinksToOpen: [URL] = []
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Handle open from unactive state
        if let url = connectionOptions.urlContexts.first?.url {
            deepLinksToOpen.append(url)
        }
        
        if let url = connectionOptions.userActivities.first?.webpageURL {
            deepLinksToOpen.append(url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
 
        self.handleDeepLink(deepLinksToOpen.first)
        self.deepLinksToOpen.removeAll()
    }
    

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // Handle DeepLink
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        self.handleDeepLink(URLContexts.first?.url)
    }
    
    func handleDeepLink(_ url: URL?) {
        if let url = url {
            
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryParams = urlComponents?.queryItemsDictionary
          
            if let params = queryParams {
                let deep = DeepAction(queryParams: params)
                
                switch deep {
                case .openURL(let url):
                    UIApplication.shared.open(url)
                case .event(let action):
                    switch action {
                    case .create:
                        self.showAlert(with: "CREATE EVENT")
                    case .reload:
                        self.showAlert(with: "Reload Pressed")
                        WidgetCenter.shared.reloadAllTimelines()
                    case .response(let event):
                        if let id = event.id , let calendarID  = event.calendarID , let status = event.status {
                            self.react(eventID: id, calendarID: calendarID, status: status)
                        }
                    case .open(let event):
                        if let id = event.id , let calendarID = event.calendarID {
                            self.showAlert(with: "OPEN EVENT id: \(id), calendar: \(calendarID)")
                        }
                    case .unknown:
                        self.showAlert(with: "Unknown action")
                    }
                default:
                    self.showAlert(with: "Unknown action")
                    break
                }

            }
        }
    }
    
    // Temp alert
    func showAlert(with url: String) {
        if let rootVC = window?.rootViewController {
            // create the alert
            let alert = UIAlertController(title: "Widget DeepLink Pressed", message: url, preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            rootVC.present(alert, animated: true, completion: nil)
        }
    }

}


extension URLComponents {
    
    var queryItemsDictionary: [String : Any] {
        set(queryItemsDictionary) {
            self.queryItems = queryItemsDictionary.map {
                URLQueryItem(name: $0, value: "\($1)")
            }
        }
        get {
            var params: [String : Any] = .init()
            return queryItems?.reduce([:], { (_, item) -> [String: Any] in
                params[item.name] = item.value
                return params
            }) ?? .init()
        }
    }
    
}

// REMOVE LATER when move to main app network
extension SceneDelegate {
    
    func react(eventID: String, calendarID: String, status: String) {
        
        guard let accessToken =  UserDefaults.appGroup.object(forKey: UserDefaults.Keys.accessToken.rawValue) else {
            return
        }
        
        let headers = [
            "Authorization" : "Bearer \(accessToken)",
            "Accept"        : "application/json",
            "Content-Type"  : "application/json"
        ]

         let parameters = [
            "operationName":"ReactEvent",
            "variables": ["input" : [
                                    "uid": eventID,
                                    "calendar": calendarID,
                                    "status": status,
                                    ]
                            ],
            "query":"mutation ReactEvent($input: ReactEventWithStatusInput!) { reactEvent(input: $input) { uid calendar { uid } recurrenceID status} }"

        ] as [String : Any]
        
        sendPostRequest(
            urlString: "https://calendar.mail.ru/graphql",
            additionalHeaders: headers,
            jsonParameters: parameters) { (result) in
                
            switch result {
            case .success(_):
                self.showAlert(with: "На приглашение успешно отвечено: \(status)")
                WidgetCenter.shared.reloadAllTimelines()
            case .failure(let error):
              print("ERROR: ", error)
            }
        }
       
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
