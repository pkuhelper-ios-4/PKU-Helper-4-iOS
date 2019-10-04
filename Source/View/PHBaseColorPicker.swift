//
//  PHBaseColorPicker.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/10/2.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHBaseColorPicker: UIControl {

    static let sideSpacing = PHGlobal.sideSpacing * 0.5
    static var itemCountPerLine = 8
    static var itemSideLength: CGFloat { return (PHGlobal.screenWidth - sideSpacing * 2) / CGFloat(itemCountPerLine) }

    typealias ColorPoolSectionModel = (title: String, colors: [UIColor])
}

