//
//  Zoom.swift
//  Diver
//
//  Created by Gerald Burke on 12/10/24.
//

import Foundation
import SwiftUI

/// A class that manages the state of the ZoomView.
@MainActor @Observable final class Zoom {
    struct Item: Hashable, Identifiable {
        var id: String { url.absoluteString }
        let url: URL
        let image: Image
        func hash(into hasher: inout Hasher) {
            hasher.combine(url)
        }
    }
    let animation: Namespace.ID
    var item: Item?
    init(animation: Namespace.ID) {
        self.animation = animation
    }
}
