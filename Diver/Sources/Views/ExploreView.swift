//
//  ExploreView.swift
//  Diver
//
//  Created by Gerald Burke on 10/25/24.
//

import SwiftUI

struct ExploreView: View {
    @Environment(Authors.self) var authors
    @Environment(Navigator.self) var navigator
    @State private var searchText: String = ""
    
    var body: some View {
        List {
            Section {
                ForEach(authors.displayed) { author in
                    ProfileView(account: author)
                }
            }
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            authors.search(searchText)
        }
        .overlay {
            if authors.displayed.isEmpty {
                ContentUnavailableView.search
            }
        }
    }
}

#Preview {
    ExploreView()
}
