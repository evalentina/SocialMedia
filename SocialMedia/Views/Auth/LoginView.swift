//
//  LoginView.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 07.04.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var isShowingLoginError: Bool = false
    @State private var createAccount : Bool = false
    @State private var errorMessage : String = ""
    @State private var isLoading: Bool = false
    
    // MARK: UserDefaults
    @AppStorage(AppStorageInfo.logStatus.rawValue) private var logStatus: Bool = false
    @AppStorage(AppStorageInfo.imageURL.rawValue) private var imageURL: URL?
    @AppStorage(AppStorageInfo.userName.rawValue) private var userNameStored: String = ""
    @AppStorage(AppStorageInfo.userID.rawValue) private var userID: String = ""
    
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
            isLoading ? LoadingView(isShowing: $isLoading) : nil
        })
        // MARK: When user data is entered incorrectly
        .alert(errorMessage, isPresented: $isShowingLoginError, actions: {})
    }
    
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
            TextField("Enter your email...", text: $email)
                .textFieldModifier(fontSize: 18, backgroundColor: .white, textColor: .black)
                .autocapitalization(.none)
            
            SecureField("Enter your password...", text: $password)
                .textContentType(.password)
                .autocapitalization(.none)
                .textFieldModifier(fontSize: 18, backgroundColor: .white, textColor: .black)
        }
    }
    
    // MARK: Login Button
    var loginButton: some View {
        Button("Login", action: {
            loginUser()
        })
        .padding()
        .foregroundColor(.white)
        .font(.helvetica(.bold, size: 20))
        .disabled(isButtonDisabled())
        .opacity(isButtonDisabled() ? 0.5 : 1)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [ .buttonFirstColor, .buttonSecondColor]),
                        startPoint: .leading,
                        endPoint: .trailing))
                .addBorder(Color.white, width: isButtonDisabled() ? 0 : 1, cornerRadius: 15)
            
                .frame(width: 300, height: 50)
        )
        .animation(.easeIn(duration: 1), value: isButtonDisabled())
    }
    
    // MARK: Register Text and Button
    var registerPageButton: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.white)
                .font(.helvetica(.light, size: 16))
            
            Button {
                createAccount.toggle()
            } label: {
                Text("Register Now")
                    .foregroundColor(.white)
                    .font(.helvetica(.medium, size: 17))
            }
        }
        .fullScreenCover(isPresented: $createAccount) {
            SigninView()
        }
    }
    
    func loginUser() {
        closeAllKeyboards()
        isLoading = true
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                try await fetchUserData()
            } catch {
                await setError(error)
            }
        }
        
    }
    
    // MARK: If user was found in data base than fetch data from Firestore
    func fetchUserData() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        await MainActor.run(body: {
            self.userID = userID
            userNameStored = user.userName
            imageURL = user.userImageURL
            logStatus = true
        })
    }
    
    func setError(_ error: Error) async {
        
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            isShowingLoginError.toggle()
            isLoading = false
        })
        
    }
    
    func isButtonDisabled() -> Bool {
        if email == "" || password == "" {
            return true
        } else {
            return false
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


