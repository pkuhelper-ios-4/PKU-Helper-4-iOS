//
//  PHTabBarController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/6.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit

class PHTabBarController: UITabBarController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        let holeViewController = PHNavigationController(rootViewController: PHHoleMainViewController.shared)
        holeViewController.tabBarItem = UITabBarItem(title: "PKU Hole", image: R.image.tabbar.chat(), tag: 1)

        let mypkuViewController = PHNavigationController(rootViewController: PHMyPKUMainViewController.shared)
        mypkuViewController.tabBarItem = UITabBarItem(title: "My PKU", image: R.image.tabbar.home(), tag: 2)

        let messageViewController = PHNavigationController(rootViewController: PHMessageMainViewController())
        messageViewController.tabBarItem = UITabBarItem(title: "Message", image: R.image.message(), tag: 3)

        let settingViewController = PHNavigationController(rootViewController: PHSettingMainViewController.shared)
        settingViewController.tabBarItem = UITabBarItem(title: "Setting", image: R.image.tabbar.settings(), tag: 4)

        let testViewController = PHNavigationController(rootViewController: PHTestMainViewController())
        testViewController.tabBarItem = UITabBarItem(title: "Test", image: R.image.support(), tag: 5)

        viewControllers = [
//            messageViewController,
            holeViewController,
//            testViewController,
            mypkuViewController,
            settingViewController,
        ]
        selectedIndex = 2

        tabBar.backgroundColor = .clear

        tabBarItem.setTitleTextAttributes([.font: PHGlobal.font.tiny], for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
**/
