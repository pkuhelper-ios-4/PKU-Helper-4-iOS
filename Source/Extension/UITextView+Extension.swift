//
//  UITextView+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

extension UITextView {

    var isSelected: Bool {
        return selectedRange.length > 0
    }

    func resizeToFitHeight() {
        let fixedWidth = self.frame.size.width
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        self.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
}
