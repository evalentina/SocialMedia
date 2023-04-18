//
//  Modifiers.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 10.04.2023.
//

import SwiftUI

struct TextFieldModifier: ViewModifier {
    let fontSize: CGFloat
    let backgroundColor: Color
    let textColor: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .font(.helvetica(.medium, size: fontSize))
            .padding(.horizontal, 10)
            .frame(width: 300, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundColor))
        
            .padding(.vertical, 10)
        
    }
}


