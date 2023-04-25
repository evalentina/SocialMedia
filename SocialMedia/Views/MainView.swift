//
//  MainView.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 07.04.2023.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var viewModel = TabBarViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $viewModel.selectedTab) {
                    if viewModel.selectedTab.rawValue == 0 {
                        PostsView()
                    } else {
                        ProfileView()
                    }
                }.preferredColorScheme(.dark)
            }
            VStack {
                Spacer()
                CustomTabBar(viewModel: viewModel)
            }
        }
        
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
