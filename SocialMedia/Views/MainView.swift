//
//  MainView.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 07.04.2023.
//

import SwiftUI

struct MainView: View {
    
    @State private var selectedTab: Tabs = .content
    
    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $selectedTab) {
                    if selectedTab.rawValue == 0 {
                        PostsView()
                    } else {
                        ProfileView()
                    }
                }.preferredColorScheme(.dark)
            }
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
