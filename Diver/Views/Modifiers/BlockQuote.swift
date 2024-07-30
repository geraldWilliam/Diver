//
//  BlockQuote.swift
//  Diver
//
//  Created by Gerald Burke on 7/30/24.
//

import SwiftUI

struct BlockQuote: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Rectangle()
                .frame(maxWidth: 2)
                .foregroundStyle(Color.gray)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 1, height: 1)))
            content
                .padding(.leading)
        }
    }
}

extension View {
    func blockQuote() -> some View {
        modifier(BlockQuote())
    }
}
