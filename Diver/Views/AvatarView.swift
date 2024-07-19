//
//  AvatarView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

struct AvatarView: View {
    let path: String
    let diameter: CGFloat
    var body: some View {
        if let url = URL(string: path) {
            AsyncImage(url: url) { result in
                if let image = result.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: diameter, height: diameter)
                        .clipShape(Circle())
                        .shadow(radius: 2, x: -1, y: 1)
                        .overlay {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        }
                } else {
                    Image(systemName: "person.fill")
                }
            }
        } else {
            Image(systemName: "person.fill")
        }
    }
}

#Preview {
    AvatarView(path: "", diameter: 40)
}
