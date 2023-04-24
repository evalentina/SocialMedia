//
//  CreateNewPostViewModel.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 19.04.2023.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage

final class CreateNewPostViewModel: ObservableObject {
    
    @Published var postText = ""
    @Published var postImageData: Data?
    
    @Published var errorMessage : String = ""
    @Published var isLoading: Bool = false
    @Published var isShowingError: Bool = false
    @Published var isPickerShowing: Bool = false
    @Published var selectedImageData: Data?
    
    // FocusState
    @Published var isKeyboardShowing: Bool = false
    // Dismiss
    @Published var goBack: Bool = false
    // MARK: UserDefaults
    @Published var settings = SettingsManager.shared
    
    @Published var onPost: (Post) -> ()
    
    init(onPost: @escaping (Post) -> ()) {
        self.onPost = onPost
    }
    
    func createPost() {
        isLoading = true
        isKeyboardShowing = false
        Task {
            do {
                guard let imageURL = settings.imageURL else {
                    return
                }
                let imageReferenceID = "\(settings.userID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
                if let postImageData = postImageData {
                    
                    let _ = try await storageRef.putDataAsync(postImageData)
                    let downloadURL = try await storageRef.downloadURL()
                    
                    let post = Post(text: postText, imageURL: downloadURL, imageReferenceID: imageReferenceID, userName: settings.userNameStored, userUID: settings.userID, userImageURL: imageURL)
                    try await createDocumentAtFirebase(post)
                    
                } else {
                    
                    let post = Post(text: postText, userName: settings.userNameStored, userUID: settings.userID, userImageURL: imageURL)
                    try await createDocumentAtFirebase(post)
                }
                


            } catch {
                await setError(error)
            }
        }
    }
    
    func createDocumentAtFirebase(_ post: Post) async throws {
        
        let doc = Firestore.firestore().collection("Posts").document()
        let _ = try doc.setData(from: post, completion: { error in
            if error == nil {
                self.isLoading = false
                var updatedPost = post
                updatedPost.id = doc.documentID
                //self.onPost(updatedPost)
                self.goBack.toggle()
            }
            
        })
    }
    
    func setError(_ error: Error) async {
        
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            isShowingError.toggle()
            isLoading = false
        })
        
    }
}

    
