//
//  LoginViewModel.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 18.04.2023.
//

import FirebaseAuth
import FirebaseFirestore

final class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isShowingLoginError: Bool = false
    @Published var createAccount : Bool = false
    @Published var errorMessage : String = ""
    @Published var isLoading: Bool = false
    
    // MARK: UserDefaults
    @Published var settings = SettingsManager.shared
    
    func loginUser() {
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
            self.settings.userID = userID
            settings.userNameStored = user.userName
            settings.imageURL = user.userImageURL
            settings.logStatus = true
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
