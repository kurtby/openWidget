//
//  URLImageView.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 13.02.21.
//

import SwiftUI

struct URLImageView: View {
    let url: URL

    @ViewBuilder
    var body: some View {
        if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            #warning("Maybe Change to placeholder from design? Or make empty view")
            if let placeholder = UIImage(named: "user") {
                Image(uiImage: placeholder)
                    .resizable()
            }
        }
    }
}

