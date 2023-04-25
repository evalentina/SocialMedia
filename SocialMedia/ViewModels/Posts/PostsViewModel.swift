//
//  PostsViewModel.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 24.04.2023.
//

import Firebase

@MainActor
final class PostsViewModel: ObservableObject {
    
    @Published var basedOnUID: Bool = false
    @Published var uid: String = ""
    @Published var posts: [Post] = []
    @Published var isFetching: Bool = true
    @Published var paginationDoc: QueryDocumentSnapshot?
    
    init(basedOnUID: Bool = false, uid: String = "", posts: [Post] = []) {
        self.basedOnUID = basedOnUID
        self.uid = uid
        self.posts = posts
    }
    
    func fetchPosts() async {
        do {
            var query: Query!
            if let paginationDoc = paginationDoc {
                query = Firestore.firestore().collection("Posts").order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Posts").order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }
            // MARK: Filter the posts which is not belong to this uid
            
            if basedOnUID {
                query = query
                    .whereField("userUID", isEqualTo: uid)
                
            }
            
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts.append(contentsOf: fetchedPosts)
                paginationDoc = docs.documents.last
                isFetching = false
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func refrechData() async {
        guard !basedOnUID else { return }
        isFetching = true
        posts = []
        paginationDoc = nil
        await self.fetchPosts()
    }
    
    func taskData() async {
        // MARK: Fetching only one time
        
        guard posts.isEmpty else { return }
        await fetchPosts()
    }
    
    
    
    
    
}
