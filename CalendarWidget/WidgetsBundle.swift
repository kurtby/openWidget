//
//  WidgetBundle.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 19.02.21.
//

import SwiftUI
import WidgetKit

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        CalendarWidgetBundle().body
    }
}

struct CalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        CalendarWidget()
    }
}
