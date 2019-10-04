//
//  UIScrollView+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

//
// https://stackoverflow.com/questions/7706152/iphone-knowing-if-a-uiscrollview-reached-the-top-or-bottom
//
extension UIScrollView {

    var isScrolledToTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }

    var isScrolledToBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }

    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }

    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}

//
// https://stackoverflow.com/questions/4132993/getting-the-current-page
//
extension UIScrollView {

    var currentPage: Int {
//        return Int((contentOffset.x + (0.5 * frame.width)) / frame.width)
        return Int(contentOffset.x / frame.width)
    }
}

//
// https://stackoverflow.com/questions/1926810/change-page-on-uiscrollview
//
extension UIScrollView {

    func scrollTo(horizontalPage: Int, verticalPage: Int = 0, animated: Bool = true) {
        var frame: CGRect = self.frame
        frame.origin.x = frame.size.width * CGFloat(horizontalPage)
        frame.origin.y = frame.size.width * CGFloat(verticalPage)
        self.scrollRectToVisible(frame, animated: animated)
    }
}
