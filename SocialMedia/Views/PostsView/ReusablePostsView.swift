//
//  ReusablePostsView.swift
//  Try
//
//  Created by Валентина Евдокимова on 01.04.2023.
//

import SwiftUI
import Firebase

struct ReusablePostsView: View {
    
    @ObservedObject var viewModel: PostsViewModel
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            LazyVStack {
                if viewModel.isFetching {
                    ProgressView()
                        .frame(width: UIScreen.screenWidth/2, height: UIScreen.screenHeight/2)
                } else {
                    if viewModel.posts.isEmpty {
                        // MARK: No post found in firebase
                        
                        Text("No posts found")
                            .font(.helvetica(.medium, size: 18))
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                    } else {
                        // MARK: Displaying posts
                        
                        posts()
                    }
                }
            }
            
        }
        .refreshable{
            await viewModel.refrechData()
        }
        .task {
            await viewModel.taskData()
        }
        
        .padding(12)        
    }
}
private extension ReusablePostsView {
    // MARK: Dispaying fetched posts
    @ViewBuilder
    func posts() -> some View {
        ForEach(viewModel.posts) { post in
            VStack {
                PostCardView(viewModel: PostCardViewModel(post: post) { updatedPost in
                    
                    if let index = viewModel.posts.firstIndex(where: { post in
                        post.id == updatedPost.id
                    }) {
                        viewModel.posts[index].likedIDs = updatedPost.likedIDs
                        viewModel.posts[index].dislikedIDs = updatedPost.dislikedIDs
                    }
                    
                } onDelete: {
                    // Removing posts from the array
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.posts.removeAll { post.id == $0.id }
                        
                    }
                    
                })
                .onAppear {
                    
                    // MARK: When last post appear fetching new post
                    if post.id == viewModel.posts.last?.id && viewModel.paginationDoc != nil {
                        Task {
                            await viewModel.fetchPosts()
                        }
                    }
                    
                }
                
                Divider()
                    .background(Color.black)
                
            }
        }
        
    }
    
}



