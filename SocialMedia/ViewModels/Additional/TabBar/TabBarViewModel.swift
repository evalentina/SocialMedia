//
//  TabBarViewModel.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 25.04.2023.
//

import Foundation

final class TabBarViewModel: ObservableObject {
    
    @Published var createNewPost: Bool = false
    @Published var recentPosts: [Post] = []
    @Published var selectedTab: Tabs = .content
    
}
