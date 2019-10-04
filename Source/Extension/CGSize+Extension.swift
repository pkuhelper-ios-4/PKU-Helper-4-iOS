//
//  CGSize+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/9.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import CoreGraphics

// MARK: - Methods
public extension CGSize {

    /// SwifterSwift: Returns the aspect ratio.
    var aspectRatio: CGFloat {
        return height == 0 ? 0 : width / height
    }
}

// MARK: - Methods
public extension CGSize {

    /// SwifterSwift: Aspect fit CGSize.
    ///
    ///     let rect = CGSize(width: 120, height: 80)
    ///     let parentRect  = CGSize(width: 100, height: 50)
    ///     let newRect = rect.aspectFit(to: parentRect)
    ///     //newRect.width = 75 , newRect = 50
    ///
    /// - Parameter boundingSize: bounding size to fit self to.
    /// - Returns: self fitted into given bounding size
    func aspectFit(to boundingSize: CGSize) -> CGSize {
        let minRatio = min(boundingSize.width / width, boundingSize.height / height)
        return CGSize(width: width * minRatio, height: height * minRatio)
    }

    /// SwifterSwift: Aspect fill CGSize.
    ///
    ///     let rect = CGSize(width: 20, height: 120)
    ///     let parentRect  = CGSize(width: 100, height: 60)
    ///     let newRect = rect.aspectFit(to: parentRect)
    ///     //newRect.width = 100 , newRect = 60
    ///
    /// - Parameter boundingSize: bounding size to fill self to.
    /// - Returns: self filled into given bounding size
    func aspectFill(to boundingSize: CGSize) -> CGSize {
        let minRatio = max(boundingSize.width / width, boundingSize.height / height)
        let aWidth = min(width * minRatio, boundingSize.width)
        let aHeight = min(height * minRatio, boundingSize.height)
        return CGSize(width: aWidth, height: aHeight)
    }
}

// MARK: - Operators
public extension CGSize {

    /// SwifterSwift: Multiply a CGSize with a scalar.
    ///
    ///     let sizeA = CGSize(width: 5, height: 10)
    ///     let result = sizeA * 5
    ///     //result = CGSize(width: 25, height: 50)
    ///
    /// - Parameters:
    ///   - lhs: CGSize to multiply.
    ///   - scalar: scalar value.
    /// - Returns: The result comes from the multiplication of the given CGSize and scalar.
    static func * (lhs: CGSize, scalar: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * scalar, height: lhs.height * scalar)
    }
}


extension CGSize {

    init(side: CGFloat) {
        self.init(width: side, height: side)
    }
}
