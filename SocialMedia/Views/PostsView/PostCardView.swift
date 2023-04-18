//
//  PostCardView.swift
//  Try
//
//  Created by Валентина Евдокимова on 01.04.2023.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import SDWebImageSwiftUI
import FirebaseStorage

struct PostCardView: View {
    
    var post: Post
    var onUpdate: (Post) -> ()
    var onDelete: () -> ()
    
    // MARK: For live updates
    @State private var docListener: ListenerRegistration?
    
    // MARK: UserDefaults
    @AppStorage(AppStorageInfo.userID.rawValue) private var userID: String = ""
    
    var body: some View {
        HStack {
            
            webImage
            
            postInformation
  
        }
        .hAlign(.leading)
        .background(Color.darkColor)
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing, content: {
            // MARK: Delete post if it's author's post
            
            if post.userUID == userID {
                Menu {
                    Button("Delete Post", role: .destructive, action: deletePost)
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
            if docListener == nil {
                guard let postID = post.id else { return }
                docListener = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapShot, error in
                    if let snapShot = snapShot {
                        if snapShot.exists {
                            // Document updated
                            if let updatedPost = try? snapShot.data(as: Post.self) {
                                onUpdate(updatedPost)
                            }
                        } else {
                            // MARK: Document deleted
                            onDelete()
                        }
                    }
                })
            }
        }
        .onDisappear {
            if let docListener = docListener {
                docListener.remove()
                self.docListener = nil
            }
        }
    }
    
    // MARK: User's image
    var webImage: some View {
        WebImage(url: post.userImageURL)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 50, height: 50)
            .clipShape(Circle())
    }
    
    var postInformation: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            Text(post.userName)
                .font(.helvetica(.light, size: 18))
            
            Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                .font(.helvetica(.light, size: 14))
                .foregroundColor(.gray)
            
            Text(post.text)
                .font(.helvetica(.medium, size: 18))
                .padding(5)
            
            if let postImage = post.imageURL {
                GeometryReader {
                    let size = $0.size
                    
                    WebImage(url: postImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
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
            Button(action: likePost){
                Image(systemName: post.likedIDs.contains(userID) ? ImageName.thumbsupFill.rawValue : ImageName.thumbsup.rawValue)
                    .foregroundColor(.white)
            }
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: dislikePost) {
                Image(systemName: post.dislikedIDs.contains(userID) ? ImageName.thumbsdownFill.rawValue : ImageName.thumbsdown.rawValue )
                    .foregroundColor(.white)
            }
            
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .foregroundColor(.black)
        .padding(8)
        
    }
    
    func likePost() {
        Task {
            guard let postID = post.id else { return }
            if post.likedIDs.contains(userID) {
                // MARK: Removing user id from the array
                
                try await Firestore.firestore().collection("Posts").document(postID).updateData(["likedIDs": FieldValue.arrayRemove([userID])])
            } else {
                
                try await Firestore.firestore().collection("Posts").document(postID).updateData(["likedIDs": FieldValue.arrayUnion([userID]), "dislikedIDs": FieldValue.arrayRemove([userID])])
                
            }
            
        }
    }
    
    func dislikePost() {
        
        Task {
            guard let postID = post.id else { return }
            if post.dislikedIDs.contains(userID) {
                //MARK: Removing user id from the array
                
                try await Firestore.firestore().collection("Posts").document(postID).updateData(["dislikedIDs": FieldValue.arrayRemove([userID])])
            } else {
                
                try await Firestore.firestore().collection("Posts").document(postID).updateData(["likedIDs": FieldValue.arrayRemove([userID]), "dislikedIDs": FieldValue.arrayUnion([userID])])
                
            }
            
        }
    }
    
    func deletePost() {
        Task {
            
            //MARK: Delete image from firebase storage
            do {
                if post.imageReferenceID != "" {
                    try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                }
                //MARK: Delete firestore document
                
                guard let postID = post.id else { return }
                try await Firestore.firestore().collection("Posts").document(postID).delete()
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
}

struct PostCardView_Previews: PreviewProvider {
    static var previews: some View {
        PostCardView(post: Post(text: "Post Text", userName: "Yana", userUID: "vd", userImageURL: URL(string: "https://img.freepik.com/free-photo/neon-tropical-monstera-leaf-banner_53876-138943.jpg?w=2000")!)) { post in
            
        } onDelete: {
            
        }
        
    }
}



