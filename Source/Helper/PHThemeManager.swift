//
//  PHThemeManager.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension PHTheme {

}

struct PHThemeManager {

    static var theme: PHTheme {
        get {
            return Defaults[.theme]
        }
        set {
            let theme = newValue
            Defaults[.theme] = theme

            let window = UIApplication.shared.delegate?.window!
            window?.tintColor = theme.mainColor
            window?.backgroundColor = theme.backgroundColor
            
//            let appTabBarController = window?.rootViewController as! UITabBarController
////            appTabBarController.tabBar.barStyle = theme.barStyle
//            appTabBarController.tabBar.barTintColor = theme.mainColor
//            appTabBarController.tabBar.tintColor = theme.titleTextColor
////            appTabBarController.tabBar.backgroundColor = theme.mainColor
//
//            for controller: UIViewController in appTabBarController.viewControllers! {
//                if let navigationController = controller as? UINavigationController {
////                    navigationController.navigationBar.barStyle = theme.barStyle
//                    navigationController.navigationBar.barTintColor = theme.mainColor
//                    navigationController.navigationBar.tintColor = theme.titleTextColor
////                    navigationController.navigationBar.backgroundColor = theme.mainColor
//                }
//            }

//            UINavigationBar.appearance().barStyle = theme.barStyle
//            UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)
//            UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backArrow")
//            UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backArrowMaskFixed")
            
//            UITabBar.appearance().barStyle = theme.barStyle
//            UITabBar.appearance().backgroundImage = theme.tabBarBackgroundImage
    
//            let tabIndicator = UIImage(named: "tabBarSelectionIndicator")?.withRenderingMode(.alwaysTemplate)
//            let tabResizableIndicator = tabIndicator?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 2.0, bottom: 0, right: 2.0))
//            UITabBar.appearance().selectionIndicatorImage = tabResizableIndicator
    
//            let controlBackground = UIImage(named: "controlBackground")?.withRenderingMode(.alwaysTemplate)
//                .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
//            let controlSelectedBackground = UIImage(named: "controlSelectedBackground")?
//                .withRenderingMode(.alwaysTemplate)
//                .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
    
//            UISegmentedControl.appearance().setBackgroundImage(controlBackground, for: .normal, barMetrics: .default)
//            UISegmentedControl.appearance().setBackgroundImage(controlSelectedBackground, for: .selected, barMetrics: .default)
    
//            UIStepper.appearance().setBackgroundImage(controlBackground, for: .normal)
//            UIStepper.appearance().setBackgroundImage(controlBackground, for: .disabled)
//            UIStepper.appearance().setBackgroundImage(controlBackground, for: .highlighted)
//            UIStepper.appearance().setDecrementImage(UIImage(named: "fewerPaws"), for: .normal)
//            UIStepper.appearance().setIncrementImage(UIImage(named: "morePaws"), for: .normal)
    
//            UISlider.appearance().setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
//            UISlider.appearance().setMaximumTrackImage(UIImage(named: "maximumTrack")?
//                .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0.0, bottom: 0, right: 6.0)), for: .normal)
//            UISlider.appearance().setMinimumTrackImage(UIImage(named: "minimumTrack")?
//                .withRenderingMode(.alwaysTemplate)
//                .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 6.0, bottom: 0, right: 0)), for: .normal)
            
//            UISwitch.appearance().onTintColor = theme.mainColor.withAlphaComponent(0.3)
//            UISwitch.appearance().thumbTintColor = theme.mainColor
            
            NotificationCenter.default.post(name: .PHThemeChanged, object: nil)
        }
    }
}
