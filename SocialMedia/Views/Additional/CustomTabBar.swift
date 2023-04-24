//
//  CustomTabBar.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 10.04.2023.
//

import SwiftUI

struct CustomTabBar: View {
    
    @Binding var selectedTab: Tabs
    
    @State private var createNewPost: Bool = false
    @State private var recentPosts: [Post] = []
    
    var body: some View {
        HStack {
            
            ButtonOnTabBar(tab: .content, text: "Content", imageName: ImageName.homekit.rawValue)
            
            newPostButton
            
            ButtonOnTabBar(tab: .profile, text: "Profile", imageName: ImageName.person.rawValue)
            
        }
        .frame(height: 82)
        .background(Color.black)
    }
}

private extension CustomTabBar {
    
    //MARK: Buttons to go to Posts and profile Views
    @ViewBuilder
    func ButtonOnTabBar(tab: Tabs, text: String, imageName: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            GeometryReader { geo in
                if selectedTab == tab {
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [.buttonFirstColor, .buttonSecondColor], startPoint: .topTrailing, endPoint: .bottom)
                        )
                        .frame(width: geo.size.width/2, height: 4)
                        .padding(.leading, geo.size.width/4)
                }
                VStack(alignment: .center, spacing: 4) {
                    
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    Text(text)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .tint(selectedTab == tab ? .white : .gray)
    }
    
    // MARK: Button to create a new post
    var newPostButton: some View {
        Button {
            createNewPost.toggle()
        } label: {
            VStack(alignment: .center, spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [.buttonFirstColor, .buttonSecondColor], startPoint: .topTrailing, endPoint: .bottom)
                        )
                        .frame(width: 32, height: 32)
                    Image(systemName: ImageName.plus.rawValue)
                        .foregroundColor(.white)
                }
                Text("New Post")
                    .foregroundColor(.white)
            }
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPostView(viewModel: CreateNewPostViewModel(onPost:
            { post in recentPosts.insert(post, at: 0)}))
        }
    }
    
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.content))
    }
}

enum Tabs: Int, CaseIterable {
    case content = 0
    case profile = 1
}


