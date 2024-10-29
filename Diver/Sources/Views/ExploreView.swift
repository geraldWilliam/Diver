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
        VStack {
            List {
                Section {
                    TextField("Search Accounts", text: $searchText)
                    Button(action: { authors.search(searchText) }) {
                        Text("Search")
                    }
                }
                Section {
                    ForEach(authors.displayed) { author in
                        ProfileView(account: author)
                    }
                }
            }
        }
    }
}

#Preview {
    ExploreView()
}
