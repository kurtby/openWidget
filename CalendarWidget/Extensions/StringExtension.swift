//
//  StringExtension.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 10.02.21.
//

import Foundation

extension String {
    
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
}
