//
//  BubbleView.swift
//  Diver
//
//  Created by Gerald Burke on 8/2/24.
//

import SwiftUI

@MainActor struct BubbleView: View {
    @Binding var isHidden: Bool
    var body: some View {
        ZStack {
            ForEach(0..<2) { _ in
                ForEach(0..<4) { index in
                    Bubble(
                        isHidden: $isHidden,
                        startAfter: TimeInterval(index)
                    )
                }
            }
        }
    }
}

@MainActor struct Bubble: View {
    // TODO: make an array of desired diameters and select randomly from them
    @Binding var isHidden: Bool
    @State private var animating: Bool = false

    let horizontalOffset: CGFloat = .random(in: -200..<200)
    let diameter: CGFloat = .random(in: 20..<80)
    let duration: CGFloat = .random(in: 8..<12)
    let startAfter: TimeInterval

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.05))
            .frame(width: animating ? diameter : 0)
            .offset(x: horizontalOffset + .random(in: -100..<100), y: animating ? -600 : 600)
            .onAppear {
                startAnimations()
            }
    }

    private func startAnimations() {
        withAnimation(.easeIn(duration: duration).delay(startAfter)) {
            animating = true
        } completion: {
            animating = false
            if !isHidden {
                startAnimations()
            }
        }
    }
}

#Preview {
    BubbleView(isHidden: .constant(false))
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(Color.gray)
}
