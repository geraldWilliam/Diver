//
//  PostInfo+AttributedBody.swift
//  Diver
//
//  Created by Gerald Burke on 7/29/24.
//

import Foundation
import TootSDK

extension PostInfo {
    var attributedBody: AttributedString? {
        guard
            let body,
            let content = try? UIKitAttribStringRenderer().render(html: body, emojis: []).attributedString
        else {
            return nil
        }
        return AttributedString(content)
    }
}
