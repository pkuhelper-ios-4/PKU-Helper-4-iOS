//
//  PHAPIUtil.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

struct PHAPIUtil {

    static func showNetworkActivityIndicator(on viewController: UIViewController?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let viewController = viewController as? PHBaseViewController {
            viewController.isNavigationBarNetworkActivityIndicatorVisable = true
        }
    }

    static func hideNetworkActivityIndicator(on viewController: UIViewController?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let viewController = viewController as? PHBaseViewController {
            viewController.isNavigationBarNetworkActivityIndicatorVisable = false
        }
    }
}
