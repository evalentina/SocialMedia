//
//  SearchUserViewModel.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 23.04.2023.
//

import FirebaseFirestore

final class SearchUserViewModel: ObservableObject {
    
    @Published var fetchedUsers: [User] = []
    @Published var searchText: String = ""
    
    // MARK: Find the users and update the view
    func searchUser() async {
        do {
            let documents = try await Firestore.firestore().collection("Users")
                .whereField("userName", isGreaterThanOrEqualTo: searchText)
                .whereField("userName", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap { doc -> User? in try doc.data(as: User.self)
            }
            // MARK: UI must be updated on Main Thread
            await MainActor.run(body: {
                fetchedUsers = users
            })
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
