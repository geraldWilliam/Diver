//
//  PrimaryButtonStyle.swift
//  Diver
//
//  Created by Gerald Burke on 8/2/24.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Gradient(colors: [.white, Color(white: 0.95)]))
            .foregroundStyle(.primary)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(style: StrokeStyle())
            }
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        buttonStyle(PrimaryButtonStyle())
    }
}
