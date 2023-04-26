//
//  PostsView.swift
//  Try
//
//  Created by Валентина Евдокимова on 31.03.2023.
//

import SwiftUI

struct PostsView: View {
    
    @StateObject private var viewModel = PostsViewModel()

    var body: some View {
        
        NavigationStack {
            ReusablePostsView(viewModel: viewModel)
                .toolbar {
                   toolBarContent()
                }
                .toolbarBackground(.hidden)
                .background(Color.darkColor.edgesIgnoringSafeArea(.all))
        }
    }
}

private extension PostsView {
    // MARK: Toobar content
    @ToolbarContentBuilder
    private func toolBarContent() -> some ToolbarContent {
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
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
