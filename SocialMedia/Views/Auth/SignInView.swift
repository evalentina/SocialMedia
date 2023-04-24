//
//  SignInView.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 07.04.2023.
//

import SwiftUI
import PhotosUI

struct SigninView: View {
    
    @StateObject private var viewModel = SignInViewModel()
    @State private var photoItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 0) {
            
            loginImage
            
            ScrollView() {
                
                welcomeText
                
                profileView
                
                textFields
                
                signInButton
                
                loginPageButton
                
            }
            .padding(0)
            .frame(maxWidth: .infinity)
            .background(
                // MARK: Corner radius of the ScrollView
                RoundedCornersShape(corners: [.topLeft, .topRight], radius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [ .firstColor, .secondColor]),
                            startPoint: .top,
                            endPoint: .bottom)
                    )
            )
        }
        .overlay(content: {
            // MARK: LoadingView after the Sign in button has been pressed, while the user's data is being loaded
            viewModel.isLoading ? LoadingView(isShowing: $viewModel.isLoading) : nil

        })
        
        // MARK: When user data is entered incorrectly
        .alert(viewModel.errorMessage, isPresented: $viewModel.isShowingLoginError, actions: {})
        .background(Color.black)
        .ignoresSafeArea()
        .vAlign(.top)
    }
}

private extension SigninView {
    
    // MARK: Login Image
    var loginImage: some View {
        
        Image(ImageName.signInImage.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(Color.black)
            .frame(width: UIScreen.screenWidth*2/3)
            .offset(y: 30)
        
            .overlay(
                // MARK: Objects in the background of the image
                OverlayBackground()
            )
    }
    
    // MARK: Welcome text
    var welcomeText: some View {
        WelcomeTextView(mainText: "Find Friends", secondText: "Register and start chatting.")
        
    }
    
    // MARK: Profile image picker
    var profileView: some View {
        VStack {
            ZStack {
                if let userProfileImageData = viewModel.userProfileImageData, let image = UIImage(data: userProfileImageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .contentShape(Circle())
                    
                } else {
                    Image(ImageName.profileImage.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 80, height: 65, alignment: .center)
            
            Text("Select a photo")
                .font(.helvetica(.medium, size: 14))
                .foregroundColor(.white)
        }
        
        .frame(width: 200)
        .onTapGesture {
            viewModel.isPickerShowing.toggle()
        }
        .photosPicker(isPresented: $viewModel.isPickerShowing, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else { return }
                        await MainActor.run(body: {
                            viewModel.userProfileImageData = imageData
                        })
                    } catch {
                        
                    }
                }
            }
            
        }
    }
    
    // MARK: Firstname Text Field, Email Text Field and Password Secure Field
    var textFields: some View {
        VStack(spacing: 15) {
            
            TextField("Enter your first name...", text: $viewModel.firstname)
                .textFieldModifier(fontSize: 18, backgroundColor: .white, textColor: .black)
            
            
            TextField("Enter your email...", text: $viewModel.email)
                .textFieldModifier(fontSize: 18, backgroundColor: .white, textColor: .black)
                .autocapitalization(.none)
            
            SecureField("Enter your password...", text: $viewModel.password)
                .textContentType(.password)
                .autocapitalization(.none)
                .textFieldModifier(fontSize: 18, backgroundColor: .white, textColor: .black)
        }
    }
    
    // MARK: Sign in Button
    var signInButton: some View {
        Button("Sign in", action: {
            viewModel.registerUser()
        })
        .padding()
        .foregroundColor(.white)
        .font(.helvetica(.bold, size: 20))
        .disabled(viewModel.isButtonDisabled())
        .opacity(viewModel.isButtonDisabled() ? 0.5 : 1)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [ .buttonFirstColor, .buttonSecondColor]),
                        startPoint: .leading,
                        endPoint: .trailing))
                .addBorder(Color.white, width: viewModel.isButtonDisabled() ? 0 : 1, cornerRadius: 15)
                .frame(width: 300, height: 50)
            
        )
        .animation(.easeIn(duration: 1), value: viewModel.isButtonDisabled())
    }
    
    // MARK: Register Text and Button
    var loginPageButton: some View {
        HStack {
            Text("Already have an account?")
                .foregroundColor(.white)
                .font(.helvetica(.light, size: 16))
            
            Button {
                viewModel.loginInAccount.toggle()
                
            } label: {
                Text("Login Now")
                    .foregroundColor(.white)
                    .font(.helvetica(.medium, size: 17))
            }
        }
        .fullScreenCover(isPresented: $viewModel.loginInAccount) {
            LoginView()
        }
    }
}

struct SigninView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView()
        
    }
}


