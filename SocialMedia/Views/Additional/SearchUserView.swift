//
//  SearchUserview.swift
//  Try
//
//  Created by Валентина Евдокимова on 03.04.2023.
//

import SwiftUI

struct SearchUserView: View {
    
    @StateObject private var viewModel = SearchUserViewModel()
    
    // MARK: Make the SearchBar visible on a dark background
    init() {
        UISearchBar.appearance().overrideUserInterfaceStyle = .dark
    }
    
    var body: some View {
        List {
            ForEach(viewModel.fetchedUsers) { user in
                NavigationLink {
                    
                    ReusableProfileView(viewModel: ProfileViewModel(user: user))
                } label : {
                    Text(user.userName)
                        .font(.helvetica(.medium, size: 18))
                        .foregroundColor(.white)
                        .hAlign(.leading)
                }
            }
            .listRowBackground(Color.darkColor)
        }
        .background(Color.darkColor.edgesIgnoringSafeArea(.all))
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search User")
        .searchable(text: $viewModel.searchText)
        .onSubmit(of: .search,  {
            Task {
                await viewModel.searchUser()
            }
        })
        .onChange(of: viewModel.searchText, perform: { newValue in
            if newValue.isEmpty {
                viewModel.fetchedUsers = []
            }
        })
        
    }
}

struct SearchUserview_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
