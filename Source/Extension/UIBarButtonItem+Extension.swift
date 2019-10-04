//
//  UIBarButtonItem+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/3.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

    var isButtonInitialized: Bool {
        guard let buttonView = self.value(forKey: "view") as? UIView else { return false }
        for case _ as UIButton in buttonView.subviews {
            return true
        }
        return false
    }
}
