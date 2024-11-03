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
    /// The diameter of the image‘s frame. If the frame is square instead of circular, this is the side length.
    let diameter: CGFloat

    private let placeholderName = "person.fill"

    var body: some View {
        if let url = URL(string: path) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5.0)
                            .stroke(Color.primary, lineWidth: 1)
                    }
            } placeholder: {
                Image(systemName: placeholderName)
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: diameter, height: diameter)
        } else {
            Image(systemName: placeholderName)
        }
    }
}

#Preview {
    AvatarView(path: "", diameter: 40)
}
