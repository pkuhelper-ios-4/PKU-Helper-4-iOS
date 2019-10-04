//
//  PHCTCourseGridView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/3.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHCTCourseGridView: UIView {

    weak var column: PHCTCourseColumnView?

    override init(frame: CGRect) {
        super.init(frame: frame)
//        layer.borderColor = UIColor.lightGray.cgColor
//        layer.borderWidth = 1
        backgroundColor = UIColor.groupTableViewBackground
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
