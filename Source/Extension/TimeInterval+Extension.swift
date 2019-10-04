//
//  TimeInterval+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation
import SwiftDate

extension TimeInterval {

    func secondsToRelativeDate() -> String {
        return DateInRegion(seconds: self, region: PHGlobal.regionBJ).toRelative()
    }

    func formatTimestamp(to format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        return DateInRegion(seconds: self, region: PHGlobal.regionBJ).toFormat(format)
    }
}
