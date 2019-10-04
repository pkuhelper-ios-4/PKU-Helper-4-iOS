//
//  PHTheme.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

enum PHTheme: String, CaseIterable, DefaultsSerializable {

    case white
    case black
    case teal
    case blue
    case indigo
    case purple
    case pink
    case red
    case orange
    case yellow
    case green

    var mainColor: UIColor {
        switch self {
        case .white:
            return .white
        case .black:
            return .black
        case .blue:
            return Color.System.blue
        case .green:
            return Color.System.green
        case .indigo:
            return Color.System.indigo
        case .orange:
            return Color.System.orange
        case .pink:
            return Color.System.pink
        case .purple:
            return Color.System.purple
        case .red:
            return Color.System.red
        case .teal:
            return Color.System.teal
        case .yellow:
            return Color.System.yellow
        }
    }

    var barStyle: UIBarStyle {
        switch self {
        case .white:
            return .black
        default:
            return .default
        }
    }

    var navigationBackgroundImage: UIImage? {
        return nil
    }

    var tabBarBackgroundImage: UIImage? {
        return nil
    }

    var backgroundColor: UIColor {
        return .lightGray
    }

    var secondaryColor: UIColor {
        switch self {
        case .blue:
            return .blue
        default:
            return .white
        }
    }

    var titleTextColor: UIColor {
        return .black
    }

    var subtitleTextColor: UIColor {
        return .black
    }
}
