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
            .background(Color.white)
            .foregroundStyle(.primary)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(style: StrokeStyle())
            }
    }
}

extension Button {
    func primaryStyle() -> some View {
        buttonStyle(PrimaryButtonStyle())
    }
}
