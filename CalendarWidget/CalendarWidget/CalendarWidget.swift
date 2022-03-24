//
//  CalendarWidget.swift
//  CalendarWidget
//
//  Created by Valentine Eyiubolu on 8.02.21.
//

import WidgetKit
import SwiftUI

struct CalendarWidget: Widget {
    let kind = Constants.WidgetKind.calendarWidget
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind.rawValue, intent: ConfigurationIntent.self, provider: CalendarWidgetTimelineProvider()) { entry in
            CalendarWidgetEntryView(entry: entry)
                .background(Color.widgetBackground)
        }
        .configurationDisplayName(kind.displayName)
        .description(kind.description)
        .supportedFamilies([.systemLarge])
    }
}
