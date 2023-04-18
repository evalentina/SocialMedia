//
//  ReusablePostsView.swift
//  Try
//
//  Created by Валентина Евдокимова on 01.04.2023.
//

import SwiftUI
import Firebase

struct ReusablePostsView: View {
    
    var basedOnUID: Bool = false
    var uid: String = ""
    
    @Binding var posts: [Post]
    
    @State private var isFetching: Bool = true
    @State private var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                if isFetching {
                    ProgressView()
                        .frame(width: UIScreen.screenWidth/2, height: UIScreen.screenHeight/2)
                } else {
                    if posts.isEmpty {
                        // MARK: No post found in firebase
                        
                        Text("No posts found")
                            .font(.helvetica(.medium, size: 18))
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    } else {
                        // MARK: Displaying posts
                        
                        Posts()
                    }
                }
            }
            
        }

        .refreshable{
            guard !basedOnUID else { return }
            isFetching = true
            posts = []
            paginationDoc = nil
            await fetchPosts()
        }
        .task {
            // MARK: Fetching only one time
            
            guard posts.isEmpty else { return }
            await fetchPosts()
        }
        .padding(12)     
    }
    // MARK: Dispaying fetched posts
    
    @ViewBuilder
    func Posts() -> some View {
        ForEach(posts) { post in
            PostCardView(post: post) { updatedPost in
                
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }) {
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
                
            } onDelete: {
                // Removing posts from the array
                withAnimation(.easeOut(duration: 0.2)) {
                    posts.removeAll { post.id == $0.id }
                    
                }
                
            }
            .onAppear {
                
                //When last post appear fetching new post
                if post.id == posts.last?.id && paginationDoc != nil {
                    Task {
                        await fetchPosts()
                    }
                }
                
            }
            Divider()
                .padding(.horizontal, -15)
        }
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
}

