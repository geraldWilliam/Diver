//
//  AvatarView.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import SwiftUI

/// A wrapper for AsyncImage. This takes a String for the image path so we don‘t need to instantiate a URL at the call site. It shows a placeholder if a URL cannot
/// be constructed or an image is not found at the URL. A retrieved image is clipped to a circle of the specified diameter. A white border and drop shadow are
/// applied.
struct AvatarView: View {
    /// A string representation of a valid URL that points to a remote image asset.
    let path: String
    /// The diameter of the circle in which the image is displayed.
    let diameter: CGFloat

    private let placeholderName = "person.fill"

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
                    Image(systemName: placeholderName)
                }
            }
        } else {
            Image(systemName: placeholderName)
        }
    }
}

#Preview {
    AvatarView(path: "", diameter: 40)
}
