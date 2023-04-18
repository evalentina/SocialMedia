//
//  OverlayBackground.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 10.04.2023.
//

import SwiftUI

struct OverlayBackground: View {

    var body: some View {
        Image(ImageName.objects.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.screenWidth, height: 180)
    }
}
