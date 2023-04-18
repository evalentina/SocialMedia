//
//  SignInView.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 07.04.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct SigninView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var firstname: String = ""
    @State private var isPickerShowing: Bool = false
    @State private var selectedImage: UIImage?
    
    @State private var loginInAccount : Bool = false
    @State private var isShowingLoginError: Bool = false
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
            isLoading ? LoadingView(isShowing: $isLoading) : nil
            
            // MARK: Background objects
            //OverlayBackground()
        })
        // MARK: When user data is entered incorrectly
        .alert(errorMessage, isPresented: $isShowingLoginError, actions: {})
        .background(Color.black)
        .ignoresSafeArea()
        .vAlign(.top)
    }
    
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
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
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
            isPickerShowing.toggle()
        }
        .sheet(isPresented: $isPickerShowing, content: {
            ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
        })
    }
    
    // MARK: Firstname Text Field, Email Text Field and Password Secure Field
    var textFields: some View {
        VStack(spacing: 15) {
            
            TextField("Enter your email...", text: $firstname)
                .textFieldModifier(fontSize: 18, backgroundColor: .white, textColor: .black)
                .autocapitalization(.none)
            
            TextField("Enter your email...", text: $email)
                .textFieldModifier(fontSize: 18, backgroundColor: .white, textColor: .black)
                .autocapitalization(.none)
            
            SecureField("Enter your password...", text: $password)
                .textContentType(.password)
                .autocapitalization(.none)
                .textFieldModifier(fontSize: 18, backgroundColor: .white, textColor: .black)
        }
    }
    
    // MARK: Sign in Button
    var signInButton: some View {
        Button("Sign in", action: {
            registerUser()
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
    var loginPageButton: some View {
        HStack {
            Text("Already have an account?")
                .foregroundColor(.white)
                .font(.helvetica(.light, size: 16))
            
            Button {
                loginInAccount.toggle()
                
            } label: {
                Text("Login Now")
                    .foregroundColor(.white)
                    .font(.helvetica(.medium, size: 17))
            }
        }
        .fullScreenCover(isPresented: $loginInAccount) {
            LoginView()
        }
    }
    
    func isButtonDisabled() -> Bool {
        if firstname == "" || email == "" || password == "" || selectedImage == nil {
            return true
        } else {
            return false
        }
    }
    
    func registerUser() {
        closeAllKeyboards()
        isLoading = true
        Task {
            do {
                try await Auth.auth().createUser(withEmail: email, password: password)
                
                // MARK: Profile ImageInto Firebase Storage
                guard let userID = Auth.auth().currentUser?.uid else {
                    return
                }
                guard let imageData = selectedImage?.jpegData(compressionQuality: 0.5) else { return }
                let storageRef = Storage.storage().reference().child("Profile_image").child(userID)
                let _ = try await storageRef.putDataAsync(imageData)
                let downloadURL = try await storageRef.downloadURL()
               let user = User(userName: firstname, userEmail: email, userPassword: password, userImageURL: downloadURL, userUID: userID)
                
                let _ = try Firestore.firestore().collection("Users").document(userID).setData(from: user, completion: {
                    error in
                    if error == nil {
                        print("User was successfully saved")
                        userNameStored = firstname
                        self.userID = userID
                        imageURL = downloadURL
                        logStatus = true
                    }
                })

            } catch {
                // MARK: Delete an account in case of failure
                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error) async {
        
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            isShowingLoginError.toggle()
            isLoading = false
        })
         
    }
    
}

struct SigninView_Previews: PreviewProvider {
    static var previews: some View {
        SigninView()
    }
}


