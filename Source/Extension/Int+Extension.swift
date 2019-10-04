//
//  Int+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation

extension Int {

    func secondsToRelativeDate() -> String {
        return TimeInterval(self).secondsToRelativeDate()
    }
}
