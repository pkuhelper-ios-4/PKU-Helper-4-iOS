//
//  UIViewController+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/10.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

///
/// Reference: http://cn.voidcc.com/question/p-qunvcdnk-nm.html
///
extension UIViewController {

    func hideTabBar(animated: Bool) {
        guard let tabBar = tabBarController?.tabBar, !tabBar.isHidden else { return }
        if !animated {
            tabBar.isHidden = true
            return
        } else {
            var frame = tabBar.frame
            frame.origin.y = self.view.frame.size.height + frame.size.height
            UIView.animate(withDuration: 0.5, animations: {
                tabBar.frame = frame
            }, completion: { _ in
                tabBar.isHidden = true
            })
        }
    }

    func showTabBar(animated: Bool) {
        guard let tabBar = tabBarController?.tabBar, tabBar.isHidden else { return }
        if !animated {
            tabBar.isHidden = false
            return
        } else {
            tabBar.isHidden = false
            var frame = tabBar.frame
            frame.origin.y = self.view.frame.size.height - frame.size.height
            UIView.animate(withDuration: 0.5, animations: {
                tabBar.frame = frame
            })
        }
    }
}
