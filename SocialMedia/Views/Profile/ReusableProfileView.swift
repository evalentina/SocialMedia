//
//  ReusableProfileView.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 11.04.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileView: View {
    
    @ObservedObject var viewModel : ProfileViewModel

    var body: some View {
        VStack(spacing: 15) {
            
            userInformation
            
            userPosts
            
        }
        .background(Color.darkColor)
    }

}

extension ReusableProfileView {
    
    // MARK: The top stack containing user information
    var userInformation: some View {
        
        VStack(alignment: .center) {
            Spacer()
            
            WebImage(url: viewModel.user?.userImageURL).placeholder(
                Image(ImageName.placeholderImage.rawValue)
                    .resizable()
            )
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 130, height: 130)
            .clipShape(Circle())
            .overlay(
                imageOverlay
           )
            
            Text(viewModel.user?.userName ?? "")
                .font(.helvetica(.medium, size: 20))
                .foregroundColor(.white)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [ .buttonFirstColor, .buttonSecondColor]),
                                startPoint: .top,
                                endPoint: .bottom))
                        .frame(width: 100, height: 40)
                )
            
        }
        
        
        .frame(width: UIScreen.screenWidth, height: 260)
        .background(
            backgroundBanner
        )
    }
    
    // MARK: Overlay for the user's photo
    var imageOverlay: some View {
        Circle()
            .stroke(Color.black, lineWidth: 7).overlay(
                Circle()
                    .stroke(
                        LinearGradient(colors: [.buttonFirstColor, .buttonSecondColor], startPoint: .topTrailing, endPoint: .bottomLeading)
                        , lineWidth: 3)
            )
    }
    
    // MARK: Banner on the background of the top stack containing user information
    var backgroundBanner: some View {
        VStack {
            Image(ImageName.profileBanner.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    // MARK: User posts
    var userPosts: some View {
        
        VStack(alignment: .leading) {
            Text("\(viewModel.user?.userName ?? "")'s Posts:")
                .font(.helvetica(.medium, size: 20))
                .foregroundColor(.white)
                .padding(.leading, 12)
            
            ReusablePostsView(viewModel: PostsViewModel(basedOnUID: true, uid: viewModel.user?.userUID ?? "", posts: viewModel.fetchedPosts))
            
        }
        .background(Color.darkColor)
    }
 
    
}

struct ReusableProfileview_Previews: PreviewProvider {
    static var previews: some View {
        ReusableProfileView(viewModel: ProfileViewModel(user: .dummy))
    }
}

