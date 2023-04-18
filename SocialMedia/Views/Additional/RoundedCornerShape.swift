//
//  RoundedCorner.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 10.04.2023.
//

import SwiftUI

struct RoundedCornersShape: Shape {
    
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
