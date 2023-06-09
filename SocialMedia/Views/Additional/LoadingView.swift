//
//  LoadingView.swift
//  Try
//
//  Created by Валентина Евдокимова on 30.03.2023.
//

import SwiftUI

struct LoadingView: View {
    
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color.darkColor
            if isShowing {
                ProgressView()
                    .padding(15)
                    .background(Color.darkColor)
            }
        }
        .ignoresSafeArea()
        .animation(.linear(duration: 0.2), value: isShowing)
    }
}

struct LoadingView_Previews : PreviewProvider {
    static var previews: some View {
        LoadingView(isShowing: .constant(true))
    }
}

