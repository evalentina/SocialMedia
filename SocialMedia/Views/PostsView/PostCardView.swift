//
//  PostCardView.swift
//  Try
//
//  Created by Валентина Евдокимова on 01.04.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostCardView: View {

    @ObservedObject var viewModel : PostCardViewModel
    
    var body: some View {
        HStack {
            
            webImage
            
            postInformation
            
        }
        .hAlign(.leading)
        .background(Color.darkColor)
        .overlay(alignment: .topTrailing, content: {
            // MARK: Delete post if it's author's post
            
            if viewModel.post.userUID == viewModel.settings.userID {
                Menu {
                    Button("Delete Post", role: .destructive, action: viewModel.deletePost)
                } label : {
                    Image(systemName: ImageName.ellipsis.rawValue)
                        .font(.caption)
                        .rotationEffect(.degrees(-90))
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                        .padding(8)
                }
                .offset(x: 8)
            }
        })
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

}

extension PostCardView {
    
    // MARK: User's image
    var webImage: some View {
        WebImage(url: viewModel.post.userImageURL)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 50, height: 50)
            .clipShape(Circle())
    }
    
    
    var postInformation: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(viewModel.post.userName)
                .font(.helvetica(.light, size: 18))
                .frame(height: 22)
            
            Text(viewModel.post.publishedDate.formatted(date: .numeric, time: .shortened))
                .font(.helvetica(.light, size: 14))
                .foregroundColor(.gray)
                .frame(height: 22)
            
            Text(viewModel.post.text)
                .font(.helvetica(.medium, size: 18))
                .padding(5)
                .frame(minHeight: 25)
            
            if let postImage = viewModel.post.imageURL {
                GeometryReader { geometry in
                    WebImage(url: postImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(height: 200)
            }
            
            postInteraction
        }
        .foregroundColor(.white)
    }
    
    // MARK: Like and Dislike
    var postInteraction: some View {
        HStack {
            Button(action: viewModel.likePost){
                Image(systemName: viewModel.post.likedIDs.contains(viewModel.settings.userID) ? ImageName.thumbsupFill.rawValue : ImageName.thumbsup.rawValue)
                    .foregroundColor(.white)
            }
            Text("\(viewModel.post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: viewModel.dislikePost) {
                Image(systemName: viewModel.post.dislikedIDs.contains(viewModel.settings.userID) ? ImageName.thumbsdownFill.rawValue : ImageName.thumbsdown.rawValue )
                    .foregroundColor(.white)
            }
            
            Text("\(viewModel.post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(height: 25)
        .foregroundColor(.black)
        .padding(8)
        
    }
    
    
}

struct PostCardView_Previews: PreviewProvider {
    static var previews: some View {
        PostCardView(viewModel: PostCardViewModel(post: .dummy, onUpdate: { post in
            
        }, onDelete: {}))
    }
}



