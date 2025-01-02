//
//  AccountInfo+AttributedBio.swift
//  Diver
//
//  Created by Gerald Burke on 12/17/24.
//

import Foundation
import TootSDK

extension AccountInfo {
    var attributedBio: AttributedString? {
        guard
            let content = try? UIKitAttribStringRenderer().render(html: bio, emojis: []).attributedString
        else {
            return nil
        }
        return AttributedString(content)
    }
}
