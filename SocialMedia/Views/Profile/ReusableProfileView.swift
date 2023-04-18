//
//  ReusableProfileView.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 11.04.2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

struct ReusableProfileView: View {
    
    var user: User
    
    @State private var isLoading: Bool = false
    @State private var fetchedPosts: [Post] = []
    
    // MARK: UserDefaults
    @AppStorage(AppStorageInfo.logStatus.rawValue) private var logStatus: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            
            userInformation
            
            userPosts
            
        }
        .background(Color.darkColor)
    }
    
    var userInformation: some View {
        
        VStack(alignment: .center) {
            Spacer()
            
            WebImage(url: user.userImageURL).placeholder(
                Image(ImageName.profileImage.rawValue)
                    .resizable()
            )
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 130, height: 130)
            .clipShape(Circle())
            .overlay(
                imageOverlay
            )
            
            Text(user.userName)
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
        
    var imageOverlay: some View {
        Circle()
            .stroke(Color.black, lineWidth: 7).overlay(
                Circle()
                    .stroke(
                        LinearGradient(colors: [.buttonFirstColor, .buttonSecondColor], startPoint: .topTrailing, endPoint: .bottomLeading)
                        , lineWidth: 3)
            )
    }
    
    var backgroundBanner: some View {
        VStack {
            Image(ImageName.profileBanner.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    var userPosts: some View {
        
        VStack(alignment: .leading) {
            Text("\(user.userName)'s Posts:")
                .font(.helvetica(.medium, size: 20))
                .foregroundColor(.white)
                .padding(.leading, 12)
            
            ReusablePostsView(basedOnUID: true, uid: user.userUID, posts: $fetchedPosts)
            
        }
        .background(Color.darkColor)
    }
    
    func logOutUser() {
        isLoading = true
        try? Auth.auth().signOut()
        logStatus = false
    }
    
    
}

struct ReusableProfileview_Previews: PreviewProvider {
    static var previews: some View {
        ReusableProfileView(user: User(userName: "Velentin", userEmail: "evdokimova@gmail.com", userPassword: "123456", userImageURL: URL(string: "https://unsplash.com/photos/_H6wpor9mjs")!, userUID: "uerUID"))
    }
}

