//
//  SwiftDate+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/5.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import SwiftDate

extension DateInRegion {

    var startOfWeekFromMonday: DateInRegion {
        let now = self
        var startDate = now.dateAt(.startOfWeek)  // get Sunday of last weak
        if now.weekday == 1 {  // If now is Sunday, we will get Sunday of current week
            startDate = startDate - 1.weeks  // So return to last week
        }
        startDate = startDate + 1.days  // Last week Sunday -> Current week Monday
        return startDate
    }

    var weekdayStartFromMonday: Int {
        switch weekday {
        case 1: // Sunday
            return 7
        default:
            return weekday - 1
        }
    }
}
