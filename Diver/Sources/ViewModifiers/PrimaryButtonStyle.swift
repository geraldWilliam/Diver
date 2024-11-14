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
            .background(.thinMaterial)
            .foregroundStyle(configuration.isPressed ? .secondary : .primary)
            .fontWeight(.medium)
            .animation(.easeInOut, value: configuration.isPressed)
            .clipShape(.rect(cornerRadius: 5))
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(style: StrokeStyle())
            }
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        buttonStyle(PrimaryButtonStyle())
    }
}
