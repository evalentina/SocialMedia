//
//  FontAndColors.swift
//  SocialMedia
//
//  Created by Валентина Евдокимова on 10.04.2023.
//

import Foundation
import SwiftUI

enum ImageName: String {
    
    case loginImage
    case objects
    case signInImage
    case profileImage
    case profileBanner
    case ellipsis
    case magnifyingglass
    case homekit
    case plus
    case trash
    case placeholderImage
    case logOut = "rectangle.portrait.and.arrow.right"
    case person = "person.circle.fill"
    case thumbsdownFill = "hand.thumbsdown.circle.fill"
    case thumbsdown = "hand.thumbsdown.circle"
    case thumbsupFill = "hand.thumbsup.circle.fill"
    case thumbsup = "hand.thumbsup.circle"
    case add = "photo.on.rectangle"
}

enum AppStorageInfo: String {
    case imageURL = "user_image_url"
    case userName = "user_name"
    case userID = "user_ID"
    case logStatus = "log_status"
    
}

extension Color {
    
    static var firstColor : Color {
        return Color("FirstColor")
    }
    
    static var secondColor : Color {
        return Color("SecondColor")
    }
    
    static var grayColor : Color {
        return Color("GrayColor")
    }

    static var buttonFirstColor : Color {
        return Color("ButtonFirstColor")
    }
    
    static var buttonSecondColor : Color {
        return Color("ButtonSecondColor")
    }
    
    static var darkColor : Color {
        return Color("DarkBlackColor")
    }
}

extension Font {
    
    enum HelveticaFontType {
        case bold
        case medium
        case light
        
        var value: String {
            switch self {
            case .bold:
                return "HelveticaNeue-Bold"
            case .medium:
                return "HelveticaNeue-Medium"
            case .light:
                return "HelveticaNeue-Light"
            }
        }
    }
    
    static func helvetica(_ type: HelveticaFontType, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }
    
}


