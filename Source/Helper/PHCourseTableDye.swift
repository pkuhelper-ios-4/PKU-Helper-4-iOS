//
//  PHCourseTableDye.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation
import CryptoSwift

class PHCourseTableDyeAlgorithm {

    typealias Result = (
        classes: [(`class`: PHClass, course: PHCourse, bgColor: UIColor)],
        actualColorPoolSize: Int
    )

    let courses: [PHCourse]
    let currentWeek: PHClass.Week
    let colorForHiddenClass: UIColor
    let colorPool: [UIColor]
    let withHiddenClasses: Bool
    let userRandomSeed: Int

    fileprivate let classes: [Class]

    init(courses: [PHCourse],
         currentWeek: PHClass.Week,
         colorForHiddenClass: UIColor,
         colorPool: [UIColor],
         withHiddenClasses: Bool = true,
         userRandomSeed: Int = 0)
    {
        self.courses = courses
        self.currentWeek = currentWeek
        self.colorForHiddenClass = colorForHiddenClass
        self.colorPool = colorPool
        self.withHiddenClasses = withHiddenClasses
        self.userRandomSeed = userRandomSeed

        self.classes = Class.fromCourses(courses, at: currentWeek)
    }

    func solve() -> Result {

        let colorIndexForHiddenClass = PHCourseTableDyeAlgorithm.colorIndexForHiddenClass

        let (result, actualColorPoolSize) = recursivelySolve(colorPool.count)
        print(colorPool.count, actualColorPoolSize)
        debugPrint(result)

        let resultWithClasses = result.enumerated()
            .sorted(by: { lhs, rhs in
                let lclass = classes[lhs.offset]
                let rclass = classes[rhs.offset]
                if lclass.isHidden != rclass.isHidden {
                    return lclass.isHidden // hidden classes will be covered by shown classes
                } else {
                    return true
                }
            })
            .compactMap({ arg -> (PHClass, PHCourse, UIColor)? in
                let (cIndex, colorIndex) = arg
                let class_ = classes[cIndex]

                if !withHiddenClasses && class_.isHidden {
                    return nil
                }

                let color = (colorIndex == colorIndexForHiddenClass) ? colorForHiddenClass : colorPool[colorIndex - 1]
                return (class_.class, class_.course, color)
            })

        return (resultWithClasses, actualColorPoolSize)
    }
}


fileprivate extension PHCourseTableDyeAlgorithm {

    typealias Week = PHClass.Week

    class Class {

        let name: String
        let weekday: Int
        let start: Int
        let end: Int
        let week: Week
        private(set) var isHidden: Bool = false

        let course: PHCourse
        let `class`: PHClass

        init(_ course: PHCourse, _ `class`: PHClass) {
            self.course = course
            self.class = `class`

            self.name = course.name
            self.weekday = `class`.weekday
            self.start = `class`.start
            self.end = `class`.end
            self.week = `class`.week
        }

        static func fromCourses(_ courses: [PHCourse], at currentWeek: Week) -> [Class] {
            return courses
                .flatMap({ (course: PHCourse) -> [Class] in
                    guard course.isVisable else { return [] }
                    let classes: [Class] = course.classes.map { `class` in
                        let clazz = Class(course, `class`)
                        clazz.isHidden = Class.isHidden(clazz.week, at: currentWeek)
                        return clazz
                    }
                    return classes
                })
                .sorted(by: { lhs, rhs in
                    if lhs.weekday != rhs.weekday {
                        return lhs.weekday < rhs.weekday
                    } else if lhs.start != rhs.start {
                        return lhs.start < rhs.start
                    } else if lhs.end != rhs.end {
                        return lhs.end < rhs.end
                    } else {
                        return lhs.name < rhs.name
                    }
                })
        }

        static func isHidden(_ week: Week, at currentWeek: Week) -> Bool {
            if week.isSpecificWeek && currentWeek.isSpecificWeek {
                return week != currentWeek
            } else if week.isDuringHoliday {
                return !currentWeek.isDuringHoliday
            } else if week == .every {
                return currentWeek.isDuringHoliday || currentWeek.isExamWeek
            } else if week.isOddWeek {
                return !currentWeek.isOddWeek || (currentWeek.isExamWeek && !week.isExamWeek)
            } else if week.isDualWeek {
                return !currentWeek.isDualWeek || (currentWeek.isExamWeek && !week.isExamWeek)
            } else {
                return false
            }
        }
    }

    class Matrix<Element>: CustomStringConvertible {

        typealias Index = (r: Int, c: Int)

        let row: Int
        let column: Int

        fileprivate var matrix: [[Element]]

        init(_ row: Int, _ column: Int, fill: Element) {
            self.row = row
            self.column = column
            self.matrix = Array(repeating: Array(repeating: fill, count: column), count: row)
        }

        subscript(_ r: Int, _ c: Int) -> Element {
            get { return matrix[r][c] }
            set { matrix[r][c] = newValue }
        }

        subscript(at index: Index) -> Element {
            get { return self[index.r, index.c] }
            set { self[index.r, index.c] = newValue }
        }

        subscript(at row: Int) -> [Element] {
            return matrix[row]
        }

        func argwhere(_ condition: (Element) -> Bool) -> [Index] {
            var indexes: [Index] = []
            for rIndex in 0..<row {
                for cIndex in 0..<column {
                    if condition(matrix[rIndex][cIndex]) {
                        indexes.append((rIndex, cIndex))
                    }
                }
            }
            return indexes
        }

        var description: String {
            return matrix.description
        }
    }

    class SquareMatrix<Element>: Matrix<Element> {

        let size: Int

        init(_ size: Int, fill: Element) {
            self.size = size
            super.init(size, size, fill: fill)
        }
    }

    class Table: CustomStringConvertible {

        let size: Int

        fileprivate var table: [[Int]]

        init(_ size: Int) {
            self.size = size
            self.table = Array(repeating: [], count: size)
        }

        convenience init<Element>(from matrix: SquareMatrix<Element>, where condition: (Element) -> Bool) {
            self.init(matrix.size)

            for (rIndex, cIndex) in matrix.argwhere({ condition($0) }) {
                table[rIndex].append(cIndex)
            }
        }

        subscript(index: Int) -> [Int] {
            return table[index]
        }

        var description: String {
            return table.description
        }
    }
}


fileprivate extension PHCourseTableDyeAlgorithm {

    static let courseTableRow = PHClass.lessonTimes.count
    static let courseTableColumn = PHCTCourseTableView.weekdays

    static let minLesson = 1
    static let maxLesson = courseTableRow
    static let minWeekday = 1
    static let maxWeekday = courseTableColumn

    static let nullCourseIndex = -1

    static let nullColorIndex = -1
    static let colorIndexForHiddenClass = 0

    typealias CourseTableIndex = (weekday: Int, lesson: Int)
    typealias RawResult = (colorIndexes: [Int], actualColorPoolSize: Int)


    func getAdjacencyIndexes(_ `class`: Class) -> [CourseTableIndex] {

        let start = `class`.start
        let end = `class`.end
        let weekday = `class`.weekday

        var indexes: [CourseTableIndex] = []

        if start > PHCourseTableDyeAlgorithm.minLesson {
            indexes.append( CourseTableIndex(weekday, start - 1) )
        }
        if end < PHCourseTableDyeAlgorithm.maxLesson {
            indexes.append( CourseTableIndex(weekday, end + 1) )
        }
        if weekday > PHCourseTableDyeAlgorithm.minWeekday {
            indexes.append(contentsOf: (start...end).map({ CourseTableIndex(weekday - 1, $0) }))
        }
        if weekday < PHCourseTableDyeAlgorithm.maxWeekday {
            indexes.append(contentsOf: (start...end).map({ CourseTableIndex(weekday + 1, $0) }))
        }

        return indexes
    }


    func getAdjacencyMatrix() -> SquareMatrix<Bool> {

        let row = PHCourseTableDyeAlgorithm.courseTableRow
        let column = PHCourseTableDyeAlgorithm.courseTableColumn
        let nullCourseIndex = PHCourseTableDyeAlgorithm.nullCourseIndex

        let courseTable = Array(generator: { _ in Matrix<Int>(row, column, fill: nullCourseIndex) }, count: classes.count)

        for (cIndex, class_) in classes.enumerated() {
            guard !class_.isHidden else { continue }
            for lesson in class_.start...class_.end {
                courseTable[cIndex][lesson-1, class_.weekday-1] = cIndex
            }
        }

        let adjacencyMatrix = SquareMatrix<Bool>(classes.count, fill: false)

        for (cIndex, class_) in classes.enumerated() {
            guard !class_.isHidden else { continue }
            for (adjWeekday, adjLesson) in getAdjacencyIndexes(class_) {
                for matrix in courseTable {
                    let adjCIndex = matrix[adjLesson-1, adjWeekday-1]
                    guard adjCIndex != nullCourseIndex else { continue }
                    adjacencyMatrix[cIndex, adjCIndex] = true
                    adjacencyMatrix[adjCIndex, cIndex] = true
                }
            }
        }

        return adjacencyMatrix
    }


    func getConstraintMatrix() -> SquareMatrix<Bool> {

        var courses: [String: Array<Int>] = [:]

        for (cIndex, class_) in classes.enumerated() {
            guard !class_.isHidden else { continue }
            let key = class_.name
            if !courses.has(key: key) {
                courses[key] = Array<Int>()
            }
            courses[key]!.append(cIndex)
        }

        let constraintMatrix = SquareMatrix<Bool>(classes.count, fill: false)

        for cIndexes in courses.values {
            for cIndex1 in cIndexes {
                for cIndex2 in cIndexes {
                    constraintMatrix[cIndex1, cIndex2] = true
                }
            }
        }

        return constraintMatrix
    }


    func hashCodeOfString(_ string: String) -> UInt64 {
        return string.bytes.md5().enumerated().map({ (i, x) in UInt64(x) << (i * 2) }).reduce(0, &+)
    }


    func getColorIndexes(_ colorPoolSize: Int) -> [[Int]] {

        let start = PHCourseTableDyeAlgorithm.colorIndexForHiddenClass + 1
        let end = start + colorPoolSize

        let defaultColorIndexes = Array(start..<end)

        let indexes = classes.enumerated().map { (arg) -> [Int] in
            let (cIndex, class_) = arg
            let seed = hashCodeOfString(class_.name) &+ UInt64(userRandomSeed * (cIndex + 1))
            return defaultColorIndexes.shuffled(seed: seed)
        }

        return indexes
    }


    func getTraversalOrder(_ adjacencyMatrix: SquareMatrix<Bool>, _ constraintTable: Table) -> [Int] {

        var marked = Array(repeating: false, count: classes.count)
        var traversalOrder = Array(repeating: PHCourseTableDyeAlgorithm.nullCourseIndex, count: classes.count + 1)

        let adjCounts = (0..<classes.count).map { row in
            adjacencyMatrix[at: row].filter({ $0 == true }).count
        }

        let testOrder = adjCounts.enumerated().sorted(by: { $0.element > $1.element }).map({ $0.offset })
        print("adjCounts", adjCounts)
        print("testOrder", testOrder)

        var idx = 0

        func setCIndexAtCurrentIndex(_ cIndex: Int) {
            guard !marked[cIndex] else { return }
            traversalOrder[idx] = cIndex
            idx += 1
            marked[cIndex] = true
            for _cIndex in constraintTable[cIndex] {
                guard !marked[_cIndex] else { continue }
                traversalOrder[idx] = _cIndex
                idx += 1
                marked[_cIndex] = true
            }
        }

        for cIndex in testOrder {
            guard !marked[cIndex] else { continue }
            setCIndexAtCurrentIndex(cIndex)
            guard idx < classes.count else { break }

            for _cIndex in testOrder {
                guard !marked[_cIndex] else { continue }
                guard adjacencyMatrix[cIndex, _cIndex] else { continue }
                setCIndexAtCurrentIndex(_cIndex)
                guard idx < classes.count else { break }
            }
        }

        return traversalOrder
    }


    func recursivelySolve(_ colorPoolSize: Int, isOutermost: Bool = true) -> RawResult {

        let nullCourseIndex = PHCourseTableDyeAlgorithm.nullCourseIndex
        let nullColorIndex = PHCourseTableDyeAlgorithm.nullColorIndex
        let colorIndexForHiddenClass = PHCourseTableDyeAlgorithm.colorIndexForHiddenClass

        let adjacencyMatrix = getAdjacencyMatrix()
        let adjacencyTable = Table(from: adjacencyMatrix, where: { $0 == true })
        let constraintMatrix = getConstraintMatrix()
        let constraintTable = Table(from: constraintMatrix, where: { $0 == true })

        print(adjacencyTable)
        print(constraintTable)

        let colorIndexes = getColorIndexes(colorPoolSize)
        let traversalOrder = getTraversalOrder(adjacencyMatrix, constraintTable)

        var result = Array(repeating: nullColorIndex, count: classes.count)


        func isConflicted(_ cIndex: Int, _ colorIndex: Int) -> Bool {
            for (_cIndex, _colorIndex) in result.enumerated() {
                guard _cIndex != nullColorIndex else { continue }
                if _cIndex == colorIndexForHiddenClass { continue }
                if constraintMatrix[cIndex, _cIndex] { continue }
                if adjacencyMatrix[cIndex, _cIndex] && colorIndex == _colorIndex { return true }
            }
            return false
        }

        func recursivelyDye(_ currentIndex: Int) -> Bool {

            let cIndex = traversalOrder[currentIndex]

            if cIndex == nullCourseIndex {
                return true
            }

            let class_ = classes[cIndex]

            guard !class_.isHidden else {
                result[cIndex] = colorIndexForHiddenClass
                return recursivelyDye(currentIndex + 1)
            }

            for _cIndex in constraintTable[cIndex] {
                let colorIndex = result[_cIndex]

                guard colorIndex != nullColorIndex else { continue }
                guard !isConflicted(cIndex, colorIndex) else { return false }

                result[cIndex] = colorIndex

                if recursivelyDye(currentIndex + 1) {
                    return true
                } else {
                    result[cIndex] = nullColorIndex
                    return false
                }
            }

            for colorIndex in colorIndexes[cIndex] {
                guard !isConflicted(cIndex, colorIndex) else { continue }

                result[cIndex] = colorIndex

                if recursivelyDye(currentIndex + 1) {
                    return true
                } else {
                    result[cIndex] = nullColorIndex
                }
            }

            return false
        }

        if recursivelyDye(0) {
            return (result, colorPoolSize)
        } else {
            var (_result, actualColorPoolSize) = recursivelySolve(colorPoolSize + 1, isOutermost: false)
            if isOutermost {
                for (_idx, colorIndex) in _result.enumerated() {
                    if colorIndex == colorIndexForHiddenClass { continue }
                    if colorIndex <= colorPoolSize { continue }
                    let actualColorIndex = colorIndex % colorPoolSize
                    if actualColorIndex == colorIndexForHiddenClass {
                        _result[_idx] = colorIndexForHiddenClass + colorPoolSize
                    } else {
                        _result[_idx] = actualColorIndex
                    }
                }
            }
            return (_result, actualColorPoolSize)
        }
    }
}
