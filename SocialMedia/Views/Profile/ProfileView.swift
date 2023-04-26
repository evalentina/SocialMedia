//
//  ProfileView.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 07.04.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {

    @StateObject var viewModel = ProfileViewModel()

    var body: some View {
        
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                if let user = viewModel.user {
                    ReusableProfileView(viewModel: ProfileViewModel(user: user))
                        .toolbar {
                            toolBarContent()
                        }
                } else {
                    LoadingView(isShowing: $viewModel.isLoading)
                }
            }
            .background(Color.darkColor)
            .toolbarBackground(.hidden)
            .refreshable {
                await viewModel.refrechData()
            }
            .task {
                await viewModel.fetchTask()
            }
        }
    }
}

private extension ProfileView {
    
    // MARK: Toobar content
    @ToolbarContentBuilder
    private func toolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button {
                    viewModel.logOutUser()
                } label: {
                    Text("Log out")
                }
            } label : {
                Image(systemName: ImageName.ellipsis.rawValue)
                    .rotationEffect(.init(degrees: 90))
                    .tint(.white)
                    .scaleEffect(0.8)
            }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            if let user = viewModel.user {
                Text("Hello, \(user.userName.capitalized)")
                    .foregroundColor(.white)
                    .font(.helvetica(.bold, size: 25))
            }
        }
    }
}

struct Profileview_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel(user: .dummy))
    }
}
