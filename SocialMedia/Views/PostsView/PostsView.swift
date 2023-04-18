//
//  PostsView.swift
//  Try
//
//  Created by Валентина Евдокимова on 31.03.2023.
//

import SwiftUI

struct PostsView: View {
    
    @State private var recentPosts: [Post] = []
    
    init() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor.black
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
    
    var body: some View {
        
        NavigationView {
            ReusablePostsView(posts: $recentPosts)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchUserView()
                        } label: {
                            HStack {
                                Text("Search for a user")
                                    .font(.helvetica(.light, size: 14))
                                    .foregroundColor(.white)
                                Image(systemName: ImageName.magnifyingglass.rawValue)
                                    .tint(.white)
                                    .scaleEffect(0.9)
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Posts")
                            .foregroundColor(.white)
                            .font(.helvetica(.bold, size: 25))
                    }
                    
                }
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                .background(Color.darkColor.edgesIgnoringSafeArea(.all))
        }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
