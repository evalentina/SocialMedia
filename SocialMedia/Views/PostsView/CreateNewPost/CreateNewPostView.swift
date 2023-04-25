//
//  PostsView.swift
//  Try
//
//  Created by Валентина Евдокимова on 31.03.2023.
//

import SwiftUI
import PhotosUI

struct CreateNewPostView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var photoItem: PhotosPickerItem?
    @FocusState private var isKeyboardShowing: Bool
    
    @StateObject var viewModel : CreateNewPostViewModel
    
    var body: some View {
        VStack {
            
            postButton
            
            postTextFieldAndImage
            
            addImageButton
                .photosPicker(isPresented: $viewModel.isPickerShowing, selection: $photoItem)
                .onChange(of: photoItem, perform: { newValue in
                    if let newValue = newValue  {
                        Task {
                            guard let rawImageData = try? await newValue.loadTransferable(type: Data.self),
                                  let image = UIImage(data:rawImageData),
                                  let compressedImageData = image.jpegData(compressionQuality: 0.5) else { return }
                            
                            await MainActor.run(body: {
                                viewModel.postImageData = compressedImageData
                                photoItem = nil
                            })
                        }
                    }
                })
        }
        .background(Color.darkColor)
        .alert(viewModel.errorMessage, isPresented: $viewModel.isShowingError, actions: {})
        .overlay(
            viewModel.isLoading ? LoadingView(isShowing: $viewModel.isLoading) : nil
        )
        .onChange(of: isKeyboardShowing) {
            viewModel.isKeyboardShowing = $0
        }
        .onAppear {
            self.isKeyboardShowing = viewModel.isKeyboardShowing
        }
        .onChange(of: viewModel.goBack) { goBack in
            if goBack {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        
    }
    
    // MARK: Post Button and Cancel Post Button
    var postButton: some View {
        HStack {
            Button {
                viewModel.goBack.toggle()
            } label: {
                Text("Cancel")
                    .font(.helvetica(.light, size: 18))
                    .foregroundColor(.white)
            }
            .hAlign(.leading)
            
            Button {
                viewModel.createPost()
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
                if let postImageData = viewModel.postImageData {
                    if let image = UIImage(data: postImageData) {
                        GeometryReader { geometry in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
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
        TextField("", text: $viewModel.postText)
            .placeholder(when: viewModel.postText.isEmpty, placeholder: {
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
            viewModel.isPickerShowing.toggle()
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
                    viewModel.selectedImageData = nil
                }
            } label: {
                Image(systemName: ImageName.trash.rawValue)
                    .tint(.red)
            }
            .padding(10)
        }
        .background(Color.black)
    }
}

struct CreateNewPostsView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPostView(viewModel: CreateNewPostViewModel(onPost: { post in
            
        }))
    }
}
