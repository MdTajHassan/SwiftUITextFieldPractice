//
//  ContentView.swift
//  barcalys
//
//  Created by tajhassan on 19/03/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Search GitHub Users", text: $viewModel.searchText, onCommit: {
                Task { await viewModel.searchUsers() }
            })
            .textFieldStyle(.roundedBorder)
            .onChange(of: viewModel.searchText) { _ in
                viewModel.searchTextDidChange()
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding(.top, 8)
            } else {
                List(viewModel.users, id: \.id) { user in
                    VStack(alignment: .leading) {
                        Text(user.login)
                            .font(.headline)
                        Text("ID: \(user.id)")
                            .font(.subheadline)
                    }
                }
                .listStyle(.plain)
            }

            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
