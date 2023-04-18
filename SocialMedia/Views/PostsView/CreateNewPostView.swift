//
//  PostsView.swift
//  Try
//
//  Created by Валентина Евдокимова on 31.03.2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct CreateNewPostView: View {
    
    var onPost: (Post) -> ()
    
    @State private var postText = ""
    @State private var postImageData: Data?
    
    @State private var errorMessage : String = ""
    @State private var isLoading: Bool = false
    @State private var isShowingError: Bool = false
    @State private var isPickerShowing: Bool = false
    @State private var selectedImage: UIImage?
    
    // MARK: UserDefaults
    @AppStorage(AppStorageInfo.imageURL.rawValue) private var imageURL: URL?
    @AppStorage(AppStorageInfo.userName.rawValue) private var userNameStored: String = ""
    @AppStorage(AppStorageInfo.userID.rawValue) private var userID: String = ""
    
    @FocusState private var isKeyboardShowing: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            postButton
            
            postTextFieldAndImage
            
            addImageButton
                .sheet(isPresented: $isPickerShowing, content: {
                    ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
                })
                .onChange(of: selectedImage) { newValue in
                    if let newValue = newValue  {
                        Task {
                            guard let compressedData = newValue.jpegData(compressionQuality: 0.5) else { return }
                            
                            await MainActor.run(body: {
                                postImageData = compressedData
                                selectedImage = nil
                            })
                        }
                    }
                }
            
        }
        .background(Color.darkColor)
        .alert(errorMessage, isPresented: $isShowingError, actions: {})
        .overlay(
            isLoading ? LoadingView(isShowing: $isLoading) : nil
        )
        
    }
    
    // MARK: Post Button and Cancel Post Button
    var postButton: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.helvetica(.light, size: 18))
                    .foregroundColor(.white)
            }
            .hAlign(.leading)
            
            Button {
                createPost()
            } label: {
                Text("Post")
                    .font(.helvetica(.medium, size: 18))
                    .foregroundColor(.white)
                    .frame(width: 130, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [ .buttonFirstColor, .buttonSecondColor]),
                                    startPoint: .leading,
                                    endPoint: .trailing))
                    )
            }
        }
        .padding(20)
        .background(Color.black)
    }
    
    var postTextFieldAndImage: some View {
        ScrollView {
            VStack(spacing: 15) {
                textFieldPost
                
                // MARK: When we add an image to a post
                if let postImageData = postImageData {
                    if let image = UIImage(data: postImageData) {
                        GeometryReader {
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(alignment: .topLeading) {
                                    // MARK: Delete Button
                                    deleteImageButton
                                }
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                
            }
            .padding(15)
        }
        .padding(0)
        .foregroundColor(.white)
        .background(Color.darkColor)
    }
    
    var textFieldPost: some View {
        TextField("", text: $postText)
            .placeholder(when: postText.isEmpty, placeholder: {
                Text("What's happening?")
                    .foregroundColor(.grayColor)
                    .font(.helvetica(.light, size: 18))
            })
            .focused(
                $isKeyboardShowing)
            .font(.helvetica(.medium, size: 22))
    }
    
    // MARK: Add an image to a post
    var addImageButton: some View {
        Button {
            isPickerShowing.toggle()
        } label: {
            Image(systemName: ImageName.add.rawValue)
                .font(.helvetica(.medium, size: 30))
                .foregroundColor(.white)
        }
        .padding(.leading, 20)
        .padding(.top, 20)
        .hAlign(.leading)
    }
    
    // MARK: When adding an image, the delete button appears on the image
    var deleteImageButton: some View {
        HStack {
            Button {
                withAnimation(.linear(duration: 0.25)) {
                    selectedImage = nil
                }
            } label: {
                Image(systemName: ImageName.trash.rawValue)
                    .tint(.red)
            }
            .padding(10)
        }
        .background(Color.black)
    }
    
    func createPost() {
        isLoading = true
        isKeyboardShowing = false
        Task {
            do {
                guard let imageURL = imageURL else {
                    return
                }
                let imageReferenceID = "\(userID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
                if let postImageData = postImageData {
                    
                    let _ = try await storageRef.putDataAsync(postImageData)
                    let downloadURL = try await storageRef.downloadURL()
                    
                    let post = Post(text: postText, imageURL: downloadURL, imageReferenceID: imageReferenceID, userName: userNameStored, userUID: userID, userImageURL: imageURL)
                    try await createDocumentAtFirebase(post)
                    
                } else {
                    
                    let post = Post(text: postText, userName: userNameStored, userUID: userID, userImageURL: imageURL)
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
                isLoading = false
                var updatedPost = post
                updatedPost.id = doc.documentID
                onPost(updatedPost)
                dismiss()
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

struct CreateNewPostsView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPostView { _ in
            
        }
    }
}
