//
//  Posts.swift
//  Try
//
//  Created by Валентина Евдокимова on 31.03.2023.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate : Date = Date()
    var likedIDs : [String] = []
    var dislikedIDs : [String] = []
    var userName: String
    var userUID: String
    var userImageURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case text
        case imageURL
        case imageReferenceID
        case publishedDate
        case likedIDs
        case dislikedIDs
        case userName
        case userUID
        case userImageURL
    }
}

extension Post {
    
    static var dummy: Post {
        .init(text: "Dummy Text", userName: "Dummy", userUID: "0", userImageURL: URL(string: "https://img.freepik.com/free-photo/neon-tropical-monstera-leaf-banner_53876-138943.jpg?w=2000")!)
    }
}
