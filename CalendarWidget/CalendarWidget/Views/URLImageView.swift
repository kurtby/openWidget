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
        }
    }
}

