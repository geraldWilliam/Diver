//
//  CardView.swift
//  Diver
//
//  Created by Gerald Burke on 11/3/24.
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: () -> Content
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 5))
                .shadow(radius: 4)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.primary.opacity(0.4), lineWidth: 1.0)
                }
            content()
        }
    }
}

#Preview {
    CardView {
        Text("Example")
    }
}
