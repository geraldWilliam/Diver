//
//  String+Filler.swift
//  Diver
//
//  Created by Gerald Burke on 1/1/25.
//

import Foundation

extension String {
    static var filler: String {
        """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt \
        ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation \
        ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in \
        reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur \
        sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id \
        est laborum.
        """
    }

    static func filler(wordCount: Int) -> String {
        filler.split(separator: " ")[0..<wordCount].joined(separator: " ")
    }
}
