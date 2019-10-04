//
//  Dictionary+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation

// MARK: - Methods
public extension Dictionary {

    /// SwifterSwift: Check if key exists in dictionary.
    ///
    ///        let dict: [String : Any] = ["testKey": "testValue", "testArrayKey": [1, 2, 3, 4, 5]]
    ///        dict.has(key: "testKey") -> true
    ///        dict.has(key: "anotherKey") -> false
    ///
    /// - Parameter key: key to search for
    /// - Returns: true if key exists in dictionary.
    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }
}
