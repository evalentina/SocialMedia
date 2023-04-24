//
//  SocialMediaApp.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 07.04.2023.
//

import SwiftUI
import Firebase


@main
struct SocialMediaApp: App {
    
    //@AppStorage(AppStorageInfo.logStatus.rawValue) private var logStatus: Bool = false
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
           
            if SettingsManager.shared.logStatus {
                MainView()
            } else {
                LoginView()
            }
            
        }
    }
}
