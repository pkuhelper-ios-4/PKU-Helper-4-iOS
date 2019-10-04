//
//  UIColor+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension Color: DefaultsSerializable {}

public extension Color {

    var grayLevel: Double {
        let (red, green, blue) = rgbComponents
        return Double(red) * 0.299 + Double(green) * 0.578 + Double(blue) * 0.114 // to YUV mode
    }

    var isLightColorByGrayLevel: Bool {
        return grayLevel >= 192
    }
}

public extension Color {

    ///
    /// System Colors
    /// ------------------
    /// - Reference: https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/
    ///
    struct System {

        public static let blue          = Color(red:  10, green: 132, blue: 255)!

        public static let green         = Color(red:  48, green: 209, blue:  88)!

        public static let indigo        = Color(red:  94, green:  92, blue: 230)!

        public static let orange        = Color(red: 255, green: 159, blue:  10)!

        public static let pink          = Color(red: 255, green:  55, blue:  95)!

        public static let purple        = Color(red: 191, green:  90, blue: 242)!

        public static let red           = Color(red: 255, green:  69, blue:  58)!

        public static let teal          = Color(red: 100, green: 210, blue: 255)!

        public static let yellow        = Color(red: 255, green: 214, blue:  10)!
    }
}

