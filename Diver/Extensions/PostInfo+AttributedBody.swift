//
//  PostInfo+AttributedBody.swift
//  Diver
//
//  Created by Gerald Burke on 7/29/24.
//

import Foundation
import SwiftHTMLtoMarkdown
// SwiftHTMLtoMarkdown gets most of the way there but the attributed text rendering still isn‘t quite right.
// Particularly, new lines are ignored.
extension PostInfo {
    var attributedBody: AttributedString? {
        guard let content = body else {
            return nil
        }
        var document = MastodonHTML(rawHTML: content)
        try? document.parse()
        let markdown = try? document.asMarkdown()
        return try? AttributedString(markdown: markdown ?? "")
    }
}
