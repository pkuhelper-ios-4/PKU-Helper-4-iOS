//
//  PHColorPickerColorCircleCollectionViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHColorPickerColorCircleCollectionViewCell: PHColorPickerBaseCircleCollectionViewCell {

    override class var identifier: String { return "PHColorPickerColorCircleCollectionViewCell" }

    var color: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }

    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let percent = PHColorPickerBaseCircleCollectionViewCell.circleDiameterPercent
        var diameter = PHMultiColorPicker.itemSideLength * CGFloat(percent)
        var side = (PHMultiColorPicker.itemSideLength - diameter) / 2
        let lineWidth: CGFloat = 2

        if !isSelected {
            let pathRect = CGRect(origin: CGPoint(x: side, y: side), size: CGSize(side: diameter))
            let path = UIBezierPath(roundedRect: pathRect, cornerRadius: diameter / 2)
            color.setFill()
            path.fill()
        } else {
            side -= lineWidth
            diameter += lineWidth * 2
            let pathRect = CGRect(origin: CGPoint(x: side, y: side), size: CGSize(side: diameter))
            let path = UIBezierPath(roundedRect: pathRect, cornerRadius: diameter / 2)
            path.lineWidth = lineWidth
            let strokeColor: UIColor = .black
            strokeColor.setStroke()
            color.setFill()
            path.fill()
            path.stroke()
        }
    }
}
