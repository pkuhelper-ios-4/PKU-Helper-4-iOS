//
//  UIEdgeInsets+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    init(px: CGFloat, py: CGFloat) {
        self.init(top: py, left: px, bottom: py, right: px)
    }
    
}
