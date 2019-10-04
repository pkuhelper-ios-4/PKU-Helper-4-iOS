//
//  PHScore.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

class PHOverallScore: ImmutableMappable {

    let gpaISOP: Double?
    let gpa: Double?
    let credit: Double
    let courseCount: Int
    let semesterScores: [PHSemesterScore]

    required init(map: Map) throws {
        gpaISOP = try map.value("summary.isop_gpa")
        gpa = try map.value("summary.gpa")
        credit = try map.value("summary.credit")
        courseCount = try map.value("summary.count")
        semesterScores = try map.value("scores")
    }
}

class PHSemesterScore: ImmutableMappable {

    let beginYear: Int
    let endYear: Int
    let semester: Int
    let gpa: Double?
    let credit: Double
    let courseCount: Int
    let courseScores: [PHCourseScore]

    required init(map: Map) throws {
        beginYear = try map.value("year.0")
        endYear = try map.value("year.1")
        semester = try map.value("semester")
        gpa = try map.value("summary.gpa")
        credit = try map.value("summary.credit")
        courseCount = try map.value("summary.count")
        courseScores = try map.value("list").sortedByGPA(ascending: false)
    }

    static let dummyYear = -1
    static let dummySemester = -1
}

class PHCourseScore: ImmutableMappable {

    let course: String
    let score: String
    let gpa: Double?
    let credit: Double
    let type: String
    let isSummary: Bool

    required init(map: Map) throws {
        course = try map.value("course")
        score = try map.value("score")
        gpa = try map.value("gpa")
        credit = try map.value("credit")
        type = try map.value("type")
        isSummary = false
    }

    // MARK: Generate a dummy CourseScore for GPA summary

    init(name: String, gpa: Double?) {
        course = name
        score = PHCourseScore.gpa2Score(gpa)
        self.gpa = gpa
        credit = 0.0
        type = ""
        isSummary = true
    }

    static let nullScore: String = ""

    static func gpa2Score(_ gpa: Double?) -> String {
        guard let gpa = gpa, gpa >= 1.0, gpa <= 4.0 else { return nullScore }
        let score = 100.0 - ((4.0 - gpa) * 1600 / 3).squareRoot()
        return score.format("%.1f")
    }
}

extension Array where Element == PHCourseScore {

    func sortedByGPA(ascending: Bool = true) -> [Element] {
        return self.sorted { lhs, rhs in
            if let lGpa = lhs.gpa, let rGpa = rhs.gpa {
                if lGpa == rGpa {
                    return ascending ? lhs.course.transformToPinyinInitials() < rhs.course.transformToPinyinInitials()
                                     : lhs.course.transformToPinyinInitials() > rhs.course.transformToPinyinInitials()
                } else {
                    return ascending ? lGpa < rGpa : lGpa > rGpa
                }
            } else if lhs.gpa == nil && rhs.gpa == nil {
                return ascending ? lhs.course.transformToPinyinInitials() < rhs.course.transformToPinyinInitials()
                                 : lhs.course.transformToPinyinInitials() > rhs.course.transformToPinyinInitials()
            } else {
                return ascending ? lhs.gpa == nil : rhs.gpa == nil
            }
        }
    }
}
