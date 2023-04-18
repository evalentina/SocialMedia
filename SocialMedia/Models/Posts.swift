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