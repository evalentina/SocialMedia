//
//  PostsViewModel.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 22.04.2023.
//

import FirebaseFirestore
import Firebase
import FirebaseStorage

final class PostCardViewModel: ObservableObject {
    
    @Published var isFetching: Bool = true
    @Published var paginationDoc: QueryDocumentSnapshot?
    @Published var basedOnUID: Bool = false
    @Published var uid: String = ""
    
    // MARK: UserDefaults
    @Published var settings = SettingsManager.shared
    
    // MARK: For live updates
    @Published var docListener: ListenerRegistration?
    
    @Published var post: Post
    @Published var onUpdate: (Post) -> ()
    @Published var onDelete: () -> ()
    
    init(post: Post, onUpdate: @escaping (Post) -> (), onDelete: @escaping () -> ()) {
        self.post = post
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    
    func dislikePost() {
        
        Task {
            guard let postID = post.id else { return }
            if post.dislikedIDs.contains(settings.userID) {
                //MARK: Removing user id from the array
                
                try await Firestore.firestore().collection("Posts").document(postID).updateData(["dislikedIDs": FieldValue.arrayRemove([settings.userID])])
            } else {
                
                try await Firestore.firestore().collection("Posts").document(postID).updateData(["likedIDs": FieldValue.arrayRemove([settings.userID]), "dislikedIDs": FieldValue.arrayUnion([settings.userID])])
                
            }
            
        }
    }
    
    func onAppear() {
        if docListener == nil {
            guard let postID = post.id else { return }
            docListener = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapShot, error in
                if let snapShot = snapShot {
                    if snapShot.exists {
                        // Document updated
                        if let updatedPost = try? snapShot.data(as: Post.self) {
                            self.onUpdate(updatedPost)
                        }
                    } else {
                        // MARK: Document deleted
                        self.onDelete()
                    }
                }
            })
        }
    }
    
    func onDisappear() {
        if let docListener = docListener {
            docListener.remove()
            self.docListener = nil
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
    
    func likePost() {
        Task {
            guard let postID = post.id else { return }
            if post.likedIDs.contains(settings.userID) {
                // MARK: Removing user id from the array
                
                try await Firestore.firestore().collection("Posts").document(postID).updateData(["likedIDs": FieldValue.arrayRemove([settings.userID])])
            } else {
                
                try await Firestore.firestore().collection("Posts").document(postID).updateData(["likedIDs": FieldValue.arrayUnion([settings.userID]), "dislikedIDs": FieldValue.arrayRemove([settings.userID])])
                
            }
            
        }
    }
    
}
