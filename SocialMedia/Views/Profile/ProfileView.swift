//
//  ProfileView.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 07.04.2023.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

struct ProfileView: View {
    
    @State private var user: User?
    @State private var isLoading: Bool = false
    @State private var fetchedPosts: [Post] = []
    
    // MARK: UserDefaults
    @AppStorage(AppStorageInfo.logStatus.rawValue) private var logStatus: Bool = false
    
    init() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor.black
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                if let user = user {
                    ReusableProfileView(user: user)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Menu {
                                    
                                    Button {
                                        logOutUser()
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
                                Text("Hello, \(user.userName.capitalized)")
                                    .foregroundColor(.white)
                                    .font(.helvetica(.bold, size: 25))
                            }
                        }
                } else {
                    progressView
                        .navigationBarHidden(true)
                }
            }
            .background(Color.darkColor)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                // MARK: Refresh user data
                self.user = nil
                await fetchUserData()
            }
            .task {
                // Fetch only for the first time
                if self.user != nil {
                    return
                }
                await fetchUserData()
            }
            .overlay {
                isLoading ? LoadingView(isShowing: $isLoading) : nil
            }
        }
    }
    
    var progressView: some View {
        VStack {
            Spacer()
            ProgressView()
                .frame(alignment: .center)
                .background(Color.darkColor)
            Spacer()
        }
        .ignoresSafeArea()
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
        .background(Color.darkColor)
        
    }
    
    func logOutUser() {
        isLoading = true
        try? Auth.auth().signOut()
        logStatus = false
    }
    
    func fetchUserData() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let user = try? await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self) else { return }
        await MainActor.run(body: {
            self.user = user
        })
    }
}

struct Profileview_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
