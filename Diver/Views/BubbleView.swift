//
//  BubbleView.swift
//  Diver
//
//  Created by Gerald Burke on 8/2/24.
//

import SwiftUI

@MainActor struct BubbleView: View {
    // TODO: make an array of desired diameters and select randomly from them
    @Binding var isHidden: Bool
    @State private var animating: Bool = false

    let horizontalOffset: CGFloat = .random(in: -200..<200)
    let diameter: CGFloat = .random(in: 30..<120)
    let duration: CGFloat = .random(in: 7..<10)
    let startAfter: TimeInterval

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.25))
            .frame(width: diameter)
            .offset(CGSize(width: horizontalOffset, height: animating ? -600 : 600))
            .onAppear {
                startAnimations()
            }
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: duration).delay(startAfter)) {
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
    BubbleView(isHidden: .constant(false), startAfter: 0)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(Color.gray)
}
