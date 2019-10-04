//
//  AppDelegate.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import PopupDialog
import SwiftyUserDefaults
import WatchdogInspector

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // MARK: print device infomation
        let device = PHGlobal.device
        print("Hardware: \(device.hardware()); Platform: \(device.platform())")

        // MARK: setup UserDefaults first
        DefaultsKeys.updatePrefix()

        // MARK: hide Autolayout Warning
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")

        // MARK: for PopupDialog apperance
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.titleFont = PHGlobal.font.regularBold
        dialogAppearance.messageFont = PHGlobal.font.small
        dialogAppearance.messageTextAlignment = .left

        // MARK: setup FPS detector
        TWWatchdogInspector.setEnableMainthreadStallingException(false)
        TWWatchdogInspector.setUseLogs(false)

        if Defaults[.isFPSDetectorOn] {
            TWWatchdogInspector.start()
        }

        // MAKR: for development
        print(PHUser.default as Any)

        // MARK: setup window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .lightGray
//        window?.rootViewController = PHTabBarController()
        window?.rootViewController = PHNavigationController(rootViewController: PHMainViewController.shared)
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        debugPrint("application Will Resign Active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        debugPrint("application Did Enter Background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        debugPrint("application Will Enter Foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        debugPrint("application Did Become Active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        debugPrint("application Will Terminate")
    }

}

