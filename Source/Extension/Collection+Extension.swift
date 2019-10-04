//
//  Collection+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation

// MARK: - Methods
public extension Collection {

    /// SwifterSwift: Safe protects the array from out of bounds by use of optional.
    ///
    ///        let arr = [1, 2, 3, 4, 5]
    ///        arr[safe: 1] -> 2
    ///        arr[safe: 10] -> nil
    ///
    /// - Parameter index: index of element to access element.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
