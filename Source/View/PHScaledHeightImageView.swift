//
//  PHScaledHeightImageView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/10/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHScaledHeightImageView: UIImageView {

    //
    // https://stackoverflow.com/questions/41154784/how-to-resize-uiimageview-based-on-uiimages-size-ratio-in-swift-3
    //
    override var intrinsicContentSize: CGSize {
        let width = frame.width
        guard let image = self.image else {
            // In testing on iOS 12.1.4 heights of 1.0 and 0.5 were respected, but 0.1 and 0.0 led intrinsicContentSize to be ignored.
            // return CGSize(width: width, height: 1.0)
            return super.intrinsicContentSize
        }
        return CGSize(width: frame.width, height: width / image.size.aspectRatio)
    }
}
