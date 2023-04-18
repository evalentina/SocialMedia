//
//  SearchUserview.swift
//  Try
//
//  Created by Валентина Евдокимова on 03.04.2023.
//

import SwiftUI
import FirebaseFirestore

struct SearchUserView: View {
    
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    init() {
        UISearchBar.appearance().overrideUserInterfaceStyle = .dark
    }
    
    var body: some View {
        List {
            ForEach(fetchedUsers) { user in
                NavigationLink {
                    
                    ReusableProfileView(user: user)
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
        .searchable(text: $searchText)
        .onSubmit(of: .search,  {
            Task {
                await searchUser()
            }
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                fetchedUsers = []
            }
        })
        
    }
    
    func searchUser() async {
        do {
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("userName", isGreaterThanOrEqualTo: searchText)
                .whereField("userName", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap { doc -> User? in try doc.data(as: User.self)
            }
            // UI must be updated on Main Thread
            await MainActor.run(body: {
                fetchedUsers = users
            })
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct SearchUserview_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
