//
//  SignInViewModel.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 18.04.2023.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

final class SignInViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstname: String = ""
    @Published var isPickerShowing: Bool = false
    @Published var userProfileImageData: Data?
    
    @Published var loginInAccount : Bool = false
    @Published var isShowingLoginError: Bool = false
    @Published var errorMessage : String = ""
    @Published var isLoading: Bool = false
    
    // MARK: UserDefaults
    @Published var settings = SettingsManager.shared
 
    func isButtonDisabled() -> Bool {
        if firstname == "" || email == "" || password == "" || userProfileImageData == nil {
            return true
        } else {
            return false
        }
    }
    
    func registerUser() {
        isLoading = true
        Task {
            do {
                try await Auth.auth().createUser(withEmail: email, password: password)
                
                // MARK: Profile ImageInto Firebase Storage
                guard let userID = Auth.auth().currentUser?.uid else {
                    return
                }
                guard let imageData = userProfileImageData else { return }
                let storageRef = Storage.storage().reference().child("Profile_image").child(userID)
                let _ = try await storageRef.putDataAsync(imageData)
                let downloadURL = try await storageRef.downloadURL()
                let user = User(userName: firstname, userEmail: email, userPassword: password, userImageURL: downloadURL, userUID: userID)
                
                let _ = try Firestore.firestore().collection("Users").document(userID).setData(from: user, completion: {
                    error in
                    if error == nil {
                        print("User was successfully saved")
                        self.settings.userNameStored = self.firstname
                        self.settings.userID = userID
                        self.settings.imageURL = downloadURL
                        self.settings.logStatus = true
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

