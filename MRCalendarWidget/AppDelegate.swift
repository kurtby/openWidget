//
//  AppDelegate.swift
//  MRCalendarWidget
//
//  Created by Aleksandr Karimov on 01.02.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureOAuthSDK()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {        
        return MRMailSDK.sharedInstance().handle(
            url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation]
        )
    }

    private enum Constants {
        static let clientId = "685d470d9fdc4dd9be87e784f328e5e9"
        static let redirectUri = "mr-calendar-widget://"
        static let returnScheme = "mr-calendar-widget"
        static let clientSecret = "7b4dc4eed1a14563a819b5bd731ff0e5"
    }

    private func configureOAuthSDK() {
        let sdk = MRMailSDK.sharedInstance()
        sdk.initialize(
            withClientID: Constants.clientId,
            redirectURI: Constants.redirectUri
        )
        sdk.returnScheme = Constants.returnScheme
        sdk.resultType = .token
        sdk.clientSecret = Constants.clientSecret
        sdk.isProofKeyForCodeExchangeEnabled = true

//        mailSDK.internalAuthMode = kMRMailSDKInternalAuthMode_WebKit;
    }


}

