//
//  PHCourse.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire
import ObjectMapper
import SwiftDate
import SwiftyUserDefaults
import EventKit

class PHCourse: ImmutableMappable, Codable, DefaultsSerializable {

    var cid: Int?
    var name: String
    var classes: [PHClass]
    var isSync: Bool = false
    var isVisable: Bool = true

    init() {
        name = ""
        classes = []
    }

    required init(map: Map) throws {
        cid = try map.value("cid")
        name = try map.value("name")
        let _classes: [PHClass] = try map.value("classes")
        classes = _classes.flatMap { $0.toClassesWithFlatWeekSpan() }
    }

    func mapping(map: Map) {
        cid     >>> map["cid"]
        name    >>> map["name"]
        classes >>> map["classes"]
    }
}

extension PHCourse: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        let obj = PHCourse()
        obj.name = name
        obj.classes = classes.copy()
        obj.isSync = isSync
        obj.isVisable = isVisable
        return obj
    }
}

extension PHCourse: Equatable {
    static func == (lhs: PHCourse, rhs: PHCourse) -> Bool {
        return lhs.name == rhs.name
            && lhs.isSync == rhs.isSync
            && lhs.isVisable == rhs.isVisable
            && lhs.classes == rhs.classes
    }
}

extension PHCourse {

    func update(by course: PHCourse) {
        self.name = course.name
        self.isSync = course.isSync
        self.isVisable = course.isVisable
        self.classes = course.classes.flatMap { $0.toClassesWithFlatWeekSpan() }
    }
}

extension Array where Element == PHCourse {

    func sortedCourses() -> [Element] {
        return self.sorted { lhs, rhs in
            // cid == nil first
            if lhs.cid == nil && rhs.cid != nil {
                return true
            } else if lhs.cid != nil && rhs.cid == nil {
                return false
            }
            // synced first
            else if lhs.isSync != rhs.isSync {
                return lhs.isSync
            }
            // visable first
            else if lhs.isVisable != rhs.isVisable {
                return lhs.isVisable
            }
            // name initials order
            else {
                return lhs.name.transformToPinyinInitials() < rhs.name.transformToPinyinInitials()
            }
        }
    }

    mutating func sortCourses() {
        self.sort { lhs, rhs in
            if lhs.cid == nil && rhs.cid != nil {
                return true
            } else if lhs.cid != nil && rhs.cid == nil {
                return false
            } else if lhs.isSync != rhs.isSync {
                return lhs.isSync
            } else if lhs.isVisable != rhs.isVisable {
                return lhs.isVisable
            } else {
                return lhs.name.transformToPinyinInitials() < rhs.name.transformToPinyinInitials()
            }
        }
    }
}

class PHClass: ImmutableMappable, Codable {

    var weekday: Int
    var start: Int
    var end: Int
    var classroom: String
    var week: Week

    fileprivate var startWeek: Week
    fileprivate var endWeek: Week

    fileprivate static let defaultStartWeek: Week = .week1
    fileprivate static let defaultEndWeek: Week = .week16

    init() {
        weekday = 1
        start = 1
        end = 1
        classroom = ""
        week = .every
        startWeek = PHClass.defaultStartWeek
        endWeek = PHClass.defaultEndWeek
    }

    deinit {
        debugPrint("deinit \(NSStringFromClass(type(of: self)))")
    }

    required init(map: Map) throws {
        weekday = try map.value("weekday")
        start = try map.value("start")
        end = try map.value("end")
        classroom = try map.value("classroom")
        week = Week(name: try map.value("week")) ?? .every
        startWeek = Week(week: try? map.value("start_week")) ?? PHClass.defaultStartWeek
        endWeek = Week(week: try? map.value("end_week")) ?? PHClass.defaultEndWeek
    }

    func mapping(map: Map) {
        weekday    >>> map["weekday"]
        start      >>> map["start"]
        end        >>> map["end"]
        classroom  >>> map["classroom"]
        week.name  >>> map["week"]
    }
}

extension PHClass: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        let obj = PHClass()
        obj.weekday = weekday
        obj.start = start
        obj.end = end
        obj.classroom = classroom
        obj.week = week
        return obj
    }
}

extension PHClass: Equatable {

    static func == (lhs: PHClass, rhs: PHClass) -> Bool {
        return lhs.weekday == rhs.weekday
            && lhs.start == rhs.start
            && lhs.end == rhs.end
            && lhs.classroom == rhs.classroom
            && lhs.week == rhs.week
    }
}

extension PHClass: CustomStringConvertible {

    var description: String {
        return "(\(week.name)) \(weekday), \(start)-\(end) \(classroom)"
    }
}

extension PHClass {

    static let lessonTimes: [(String, String)] = [
        ("08:00", "08:50"), ("09:00", "09:50"), ("10:10", "11:00"), ("11:10", "12:00"),
        ("13:00", "13:50"), ("14:00", "14:50"), ("15:10", "16:00"), ("16:10", "17:00"),
        ("17:10", "18:00"), ("18:40", "19:30"), ("19:40", "20:30"), ("20:40", "21:30"),
    ]

    var startDate: DateInRegion {
        let (startTime, _) = PHClass.lessonTimes[start - 1]
        return startTime.toDate("HH:mm", region: PHGlobal.regionBJ)!
    }

    var endDate: DateInRegion {
        let (_, endTime) = PHClass.lessonTimes[end - 1]
        return endTime.toDate("HH:mm", region: PHGlobal.regionBJ)!
    }
}

extension PHClass {

    static private let weekdayNames: [String] = (1...7).map { weekday in
        let weekdayStart = PHGlobal.regionBJ.nowInThisRegion().dateAt(.startOfWeek) // Sun
        let date = weekdayStart + weekday.days
        return date.weekdayName(.short)
    }

    static func getWeekdayName(_ weekday: Int) -> String {
        return weekdayNames[weekday - 1]
    }
}

extension PHClass {

    //
    // .every -> [ .week1, .week2, ..., .week16, (.week17, .week18) ]
    // .odd   -> [ .week1, .week3, ..., .week15, (.week17) ]
    // .dual  -> [ .week2, .week4, ..., .week16, (.week18) ]
    //
    func toClassesWithSpecificWeeks(includeExamWeeks: Bool = false) -> [PHClass]? {
        var weeks: [Week]? = nil
        switch self.week {
        case .every:
            weeks = includeExamWeeks ? Week.allSpecificWeeks : Week.allSpecificWeeks.filter { !$0.isExamWeek }
        case .odd:
            weeks = includeExamWeeks ? Week.allOddWeeks : Week.allOddWeeks.filter { !$0.isExamWeek }
        case .dual:
            weeks = includeExamWeeks ? Week.allDualWeeks : Week.allDualWeeks.filter { !$0.isExamWeek }
        default:
            break
        }
        return weeks?.map {
            let newClass = self.copy() as! PHClass
            newClass.week = $0
            return newClass
        }
    }

    //
    // |  type  | startWeek | endWeek |
    // | ------ | --------- | ------- |
    // | .every |         1 |       8 |  -> [ .week1, .week2, ..., .week8 ]
    // | .odd   |         1 |       8 |  -> [ .week1, .week3, .week5, .week7 ]
    // | .dual  |         1 |       8 |  -> [ .week2, .week4, .week6, .week8 ]
    //
    func toClassesWithFlatWeekSpan(includeExamWeeks: Bool = false) -> [PHClass] {
        if week.isSpecificWeek || week.isDuringHoliday {
            return [self]
        } else if startWeek == PHClass.defaultStartWeek || endWeek == PHClass.defaultEndWeek {
            return [self]
        } else {
            guard var weeks = PHClass.Week.weekSpanToSpecificWeeks(startWeek, endWeek, includeExamWeeks: includeExamWeeks) else { return [] }
            switch week {
            case .odd:
                weeks = weeks.filter { $0.isOddWeek }
            case .dual:
                weeks = weeks.filter { $0.isDualWeek }
            case .every:
                break
            default:
                return []
            }
            return weeks.map {
                let newClass = self.copy() as! PHClass
                newClass.week = $0
                return newClass
            }
        }
    }
}


extension PHClass {

    enum Week: String, CaseIterable, Codable {

        case every, odd, dual

        case week1,  week2,  week3,  week4,  week5,  week6,
             week7,  week8,  week9,  week10, week11, week12,
             week13, week14, week15, week16, week17, week18

        case week0  // Week 0 means not Week 1-18

        static let maxWeek: Int = 18
        static let minWeek: Int = 1


        init?(name: String) {
            if name == "每周" {
                self = .every
            } else if name == "单周" {
                self = .odd
            } else if name == "双周" {
                self = .dual
            } else if name.isDigits {
                self.init(rawValue: "week\(name)")
            } else {
                return nil
            }
        }

        init?(week: Int?) {
            guard let week = week else { return nil }
            self.init(rawValue: "week\(week)")
        }

        var name: String {
            switch self {
            case .every:
                return "每周"
            case .odd:
                return "单周"
            case .dual:
                return "双周"
            default:
                return rawValue.removingPrefix("week")
            }
        }

        // only for view display
        var displayName: String {
            switch self {
            case .every, .odd, .dual:
                return name
            case .week0:
                return "假期"
            default:
                return "第\(name)周"
            }
        }

        var weekday: Int? {
            switch self {
            case .every, .odd, .dual:
                return nil
            default:
                return name.int
            }
        }

        init(from semesterBeginning: Date) {

            let startDate = semesterBeginning.in(region: PHGlobal.regionBJ).startOfWeekFromMonday
            let now = PHGlobal.regionBJ.nowInThisRegion()

            let delta = Int64(now.timeIntervalSince(startDate)) / (60 * 60 * 24)

            guard delta >= 0 else {
                self = .week0
                return
            }

            let week = (delta / 7) + 1

            if week < Week.minWeek { // impossible
                self = .week0
            } else if week > Week.maxWeek {
                self = .week0
            } else {
                self.init(name: String(week))!
            }
        }

        var isOddWeek: Bool {
            switch self {
            case .every, .odd:
                return true
            case .week1, .week3, .week5, .week7, .week9, .week11, .week13, .week15, .week17:
                return true
            case .week0:
                return false
            default:
                return false
            }
        }

        var isDualWeek: Bool {
            switch self {
            case .every, .dual:
                return true
            case .week2, .week4, .week6, .week8, .week10, .week12, .week14, .week16, .week18:
                return true
            case .week0:
                return false
            default:
                return false
            }
        }

        var isDuringHoliday: Bool {
            switch self {
            case .every:
                return false
            case .week0:
                return true
            default:
                return false
            }
        }

        var isSpecificWeek: Bool {
            switch self {
            case .every, .odd, .dual:
                return false
            case .week0:
                return false
            default:
                return true
            }
        }

        var isExamWeek: Bool {
            switch self {
            case .every, .odd, .dual:
                return false
            case .week0:
                return false
            case .week17, .week18:
                return true
            default:
                return false
            }
        }

        static let allOddWeeks = Week.allCases.filter { $0.isSpecificWeek && $0.isOddWeek }
        static let allDualWeeks = Week.allCases.filter { $0.isSpecificWeek && $0.isDualWeek }
        static let allSpecificWeeks = Week.allCases.filter { $0.isSpecificWeek }

        fileprivate static func weekSpanToSpecificWeeks(_ startWeek: Week, _ endWeek: Week, includeExamWeeks: Bool = false) -> [Week]? {
            guard startWeek.isSpecificWeek && endWeek.isSpecificWeek else { return nil }
            let allWeeks = includeExamWeeks ? allSpecificWeeks : allSpecificWeeks.filter { !$0.isExamWeek }
            let start = startWeek.weekday! - 1
            let end = endWeek.weekday! - 1
            guard end >= start else { return [] }
            return Array(allWeeks[start...end])
        }
    }
}
