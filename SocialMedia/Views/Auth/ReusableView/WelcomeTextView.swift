//
//  TextOverlay.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 10.04.2023.
//

import SwiftUI

struct WelcomeTextView: View {
    
    var mainText: String
    var secondText: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(mainText)
                .foregroundColor(.white)
                .font(.helvetica(.bold, size: 40))
            
            Text(secondText)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .foregroundColor(.white)
                .font(.helvetica(.light, size: 16))
                .multilineTextAlignment(.center)
        }
        .background(Color.clear)
        .frame(height: 100)
    }
}

