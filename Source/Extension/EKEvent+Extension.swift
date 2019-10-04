//
//  EKEvent+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/14.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import EventKit

extension EKEvent {

    // for course table event
    func isSameClass(with event: EKEvent) -> Bool {
        return title == event.title
            && location == event.location
            && startDate == event.startDate
            && endDate == event.endDate
    }
}

extension Array where Element == EKEvent {

    func sortedClassEvents() -> [Element] {
        return self.sorted { lhs, rhs in
            if lhs.title != rhs.title {
                return lhs.title.transformToPinyinInitials() < rhs.title.transformToPinyinInitials()
            } else if lhs.startDate != rhs.startDate {
                return lhs.startDate < rhs.startDate
            } else if lhs.endDate != rhs.endDate {
                return lhs.endDate < rhs.endDate
            } else {
                return true
            }
        }
    }
}
