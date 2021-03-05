//
//  IntentHandler.swift
//  CalendarWidgetIntentHandler
//
//  Created by Valentine Eyiubolu on 4.03.21.
//

import Intents

class IntentHandler: INExtension, ConfigurationIntentHandling {
    
    func provideCalendarTypeOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<CalendarType>?, Error?) -> Void) {
        
     //   CalendarType(identifier: <#T##String?#>, display: <#T##String#>)
    //    let collection = INObjectCollection(items: eventCategories)
      //  completion(collection, nil)
    }
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
