//
//  LoginView.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 07.04.2023.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            loginImage
            
            ScrollView() {
                
                welcomeText
                
                textFields
                
                loginButton
                
                registerPageButton
                
            }
            
            .offset(y: 25)
            .padding(15)
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
        .background(Color.black)
        .ignoresSafeArea()
        .vAlign(.top)
        .overlay(content: {
            // MARK: LoadingView after the Login button has been pressed, while the user's data is being loaded
            viewModel.isLoading ? LoadingView(isShowing: $viewModel.isLoading) : nil
        })
        // MARK: When user data is entered incorrectly
        .alert(viewModel.errorMessage, isPresented: $viewModel.isShowingLoginError, actions: {})
    }
}

private extension LoginView {
    
    // MARK: Login Image
    var loginImage: some View {
        Image(ImageName.loginImage.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(Color.black)
            .offset(y: 25)
            .overlay(
                OverlayBackground()
            )
    }
    
    // MARK: Welcome Text
    var welcomeText: some View {
        WelcomeTextView(mainText: "ReachMe",
                        secondText: "Welcome back! You've been missed.")
        
    }
    
    // MARK: Email Text Field and Password Secure Field
    var textFields: some View {
        VStack(spacing: 15) {
            TextField("Enter your email...", text: $viewModel.email)
                .textFieldModifier(fontSize: 18, backgroundColor: .white, textColor: .black)
                .autocapitalization(.none)
            
            SecureField("Enter your password...", text: $viewModel.password)
                .textContentType(.password)
                .autocapitalization(.none)
                .textFieldModifier(fontSize: 18, backgroundColor: .white, textColor: .black)
        }
    }
    
    // MARK: Login Button
    var loginButton: some View {
        Button("Login", action: {
            viewModel.loginUser()
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
    var registerPageButton: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.white)
                .font(.helvetica(.light, size: 16))
            
            Button {
                viewModel.createAccount.toggle()
            } label: {
                Text("Register Now")
                    .foregroundColor(.white)
                    .font(.helvetica(.medium, size: 17))
            }
        }
        .fullScreenCover(isPresented: $viewModel.createAccount) {
            SigninView()
            
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


