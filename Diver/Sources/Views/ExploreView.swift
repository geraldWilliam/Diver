//
//  ExploreView.swift
//  Diver
//
//  Created by Gerald Burke on 10/25/24.
//

import SwiftUI

struct ExploreView: View {
    @Environment(Accounts.self) var accounts
    @Environment(Navigator.self) var navigator
    @State private var searchText: String = ""
    
    var body: some View {
        List {
            Section {
                ForEach(accounts.searchResults) { author in
                    ProfileView(account: author)
                }
            }
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            accounts.search(searchText)
        }
        .overlay {
            if accounts.searchResults.isEmpty {
                ContentUnavailableView.search
            }
        }
    }
}

#Preview {
    ExploreView()
}
