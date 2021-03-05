//
//  ViewExtension.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 8.02.21.
//

import SwiftUI

// Condtions (if,else) for View modifiers
extension View {
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(_ condition: Bool, if ifTransform: (Self) -> TrueContent, else elseTransform: (Self) -> FalseContent) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
    
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
       if condition {
            transform(self)
       } else {
            self
       }
    }
    
}

