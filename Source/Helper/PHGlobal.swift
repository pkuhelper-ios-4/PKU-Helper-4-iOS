//
//  PHGlobal.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import DeviceGuru
import SwiftDate

struct PHGlobal {

    static let device: DeviceGuru = DeviceGuru()

    static var screenHeight: CGFloat { return UIScreen.main.bounds.height }
    static var screenWidth: CGFloat { return UIScreen.main.bounds.width }

    static var statusBarHeight: CGFloat { return UIApplication.shared.statusBarFrame.height }
    static let navBarHeight: CGFloat = PHNavigationController().navigationBar.frame.height
    static var topBarsHeight: CGFloat { return PHGlobal.statusBarHeight + PHGlobal.navBarHeight }

    static let sideSpacing: CGFloat = 15.0

    static var regionBJ: Region {
        return Region(calendar: Calendars.gregorian, zone: Zones.asiaShanghai, locale: Locales.current)
    }

    static let version: String = {
        guard let info = Bundle.main.infoDictionary else { return "Unknown" }
        let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
        return "\(appVersion) (build: \(appBuild))"
    }()

    static let font = _Font()
    static let secret = _Secret()

    struct _Font {

        let smallest = UIFont.systemFont(ofSize: FontSize.smallest)
        let tiny = UIFont.systemFont(ofSize: FontSize.tiny)
        let small = UIFont.systemFont(ofSize: FontSize.small)
        let regular = UIFont.systemFont(ofSize: FontSize.regular)
        let large = UIFont.systemFont(ofSize: FontSize.large)
        let huge = UIFont.systemFont(ofSize: FontSize.huge)
        let largest = UIFont.systemFont(ofSize: FontSize.largest)

        let smallestBold = UIFont.boldSystemFont(ofSize: FontSize.smallest)
        let tinyBold = UIFont.boldSystemFont(ofSize: FontSize.tiny)
        let smallBold = UIFont.boldSystemFont(ofSize: FontSize.small)
        let regularBold = UIFont.boldSystemFont(ofSize: FontSize.regular)
        let largeBold = UIFont.boldSystemFont(ofSize: FontSize.large)
        let hugeBold = UIFont.boldSystemFont(ofSize: FontSize.huge)
        let largestBold = UIFont.boldSystemFont(ofSize: FontSize.largest)

        private struct FontSize {

            static let smallest: CGFloat = regular - 6
            static let tiny: CGFloat = regular - 4
            static let small: CGFloat = regular - 2
            static let regular: CGFloat = getRegularFontSize()
            static let large: CGFloat = regular + 2
            static let huge: CGFloat = regular + 4
            static let largest: CGFloat = regular + 8

            private static func getRegularFontSize() -> CGFloat {
                switch PHGlobal.device.hardware() {
                case .iphone_se:
                    return UIFont.systemFontSize
                default:
                    return UIFont.systemFontSize + 2
                }
            }
        }
    }

    struct _Secret {

        let userDefaultsPrefixSalt: String = "e33be6797cbb920613bd32dc0826f852d7f0c8e334d455d07e0f25724a946049"
    }
}
