//
//  IntentHandler.swift
//  CalendarWidgetIntentHandler
//
//  Created by Valentine Eyiubolu on 4.03.21.
//

import Intents

class IntentHandler: INExtension, ConfigurationIntentHandling {
    
    func provideCalendarTypeOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<CalendarType>?, Error?) -> Void) {
        
        Network().loadCalendars { (result, error) in

            guard let calendarsData = result?.data.calendars else {
                completion(nil, nil)
                return
            }

            let calendars = calendarsData.map { (calendar) -> CalendarType in
                let eventCategory = CalendarType(identifier: calendar.uid, display: calendar.title)
                eventCategory.type = calendar.type
                return eventCategory
            }
            
            let groupData = Dictionary(grouping: calendars) { $0.type }
            
            let itemsInSections: [INObjectSection] = groupData.map { .init(title: $0.key, items: $0.value)}
            
            let collection = INObjectCollection(sections: itemsInSections)
            completion(collection, nil)
        }
    }
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
}
