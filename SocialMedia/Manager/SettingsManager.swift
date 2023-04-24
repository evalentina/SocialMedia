//
//  SettingsManager.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 18.04.2023.
//

import SwiftUI

class SettingsManager: ObservableObject {
    
    static let shared = SettingsManager()

    // MARK: UserDefaults
    @AppStorage(AppStorageInfo.logStatus.rawValue) var logStatus: Bool = false
    @AppStorage(AppStorageInfo.imageURL.rawValue) var imageURL: URL?
    @AppStorage(AppStorageInfo.userName.rawValue) var userNameStored: String = ""
    @AppStorage(AppStorageInfo.userID.rawValue) var userID: String = ""
    
}
