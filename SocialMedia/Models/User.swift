//
//  User.swift
//  Try
//
//  Created by Валентина Евдокимова on 30.03.2023.
//

import Foundation
import FirebaseFirestoreSwift
import UIKit

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var userName: String
    var userEmail: String
    var userPassword: String
    var userImageURL: URL
    var userUID: String
    
    enum CodingKeys: CodingKey {
        case id
        case userName
        case userEmail
        case userPassword
        case userImageURL
        case userUID
    }
    
}


