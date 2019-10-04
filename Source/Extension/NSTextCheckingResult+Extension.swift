//
//  NSTextCheckingResult+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/24.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation

extension NSTextCheckingResult {

    //
    // https://stackoverflow.com/questions/42789953/swift-3-how-do-i-extract-captured-groups-in-regular-expressions
    //
    func groups(in text: String) -> [String] {
        return (0..<numberOfRanges).map { index in
            let rangeBounds = self.range(at: index)
            guard let range = Range(rangeBounds, in: text) else { return "" }
            return String(text[range])
        }
    }
}
