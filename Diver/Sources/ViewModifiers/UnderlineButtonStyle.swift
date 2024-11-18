//
//  UnderlineButtonStyle.swift
//  Diver
//
//  Created by Gerald Burke on 11/15/24.
//

import SwiftUI

struct UnderlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            .padding(.leading, 12)
            .foregroundStyle(configuration.isPressed ? .secondary : .primary)
            .fontWeight(.medium)
            .animation(.easeInOut, value: configuration.isPressed)
            .overlay(Divider(), alignment: .bottom)
    }
}

extension View {
    func underlineButtonStyle() -> some View {
        buttonStyle(UnderlineButtonStyle())
    }
}

#Preview {
    VStack {
        Button(action: {}) {
            Text("Hit Me")
        }
        .underlineButtonStyle()
    }
    .background(.thinMaterial)
}
