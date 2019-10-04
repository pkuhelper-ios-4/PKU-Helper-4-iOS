//
//  PHCTCourseColumnsScrollView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/3.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class PHCTCourseColumnsScrollView: UIScrollView {

    weak var courseTable: PHCTCourseTableView?

    var courseColumnViews: [PHCTCourseColumnView] = []
    var classCellViews: [PHCTClassCellView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        scrollsToTop = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isDirectionalLockEnabled = true
        bounces = false

        for weekday in 1...PHCTCourseTableView.weekdays {
            let column = PHCTCourseColumnView()
            column.weekday = weekday
            column.delegate = self
            addSubview(column)
            courseColumnViews.append(column)
        }

        setupCourseColumnsConstraints()

        if Defaults[.courseTableDefaultExpandedTodaysCourseColumn] {
            let nowWeekday = PHGlobal.regionBJ.nowInThisRegion().weekdayStartFromMonday
            expandedColumn(courseColumnViews[nowWeekday - 1])
        }
    }

    func setupCourseColumnsConstraints() {
        let columnWidth = PHCTCourseColumnView.normalWidth

        var leftColumn = courseColumnViews[0]
        var rightColumn = leftColumn  // Temporary

        for idx in 1..<courseColumnViews.count {
            rightColumn = courseColumnViews[idx]
            leftColumn.snp.makeConstraints { make in
                make.top.height.equalToSuperview()
                make.width.equalTo(columnWidth)
                make.right.equalTo(rightColumn.snp.left)

                // MUST BE set here, one view can only be makeContraints once
                if idx == 1 {
                    make.left.equalToSuperview()
                }
            }
            leftColumn = rightColumn
        }
        rightColumn.snp.makeConstraints { make in
            make.top.height.right.equalToSuperview()
            make.width.equalTo(columnWidth)
        }
    }

    func setupClassCells() {
        guard let courses = courseTable?.courses else { return }
        classCellViews.forEach { $0.removeFromSuperview() }
        classCellViews.removeAll()

        var colorPool = Defaults[.courseTableColorPool]
        if colorPool.count == 0 {
            colorPool = PHCTClassCellView.defaultColorPool
        }

        let textColor = Defaults[.courseTableCellTextColor] ?? PHCTClassCellView.defaultTextColor
        let colorForHiddenClass = Defaults[.courseTableColorForOtherWeeksClasses] ?? PHCTClassCellView.defaultColorForHiddenClass

        let solver = PHCourseTableDyeAlgorithm(courses: courses,
                                               currentWeek: PHCTMainViewController.currentWeek ?? .every,
                                               colorForHiddenClass: colorForHiddenClass,
                                               colorPool: colorPool,
                                               withHiddenClasses: !Defaults[.courseTableHideOtherWeeksClasses],
                                               userRandomSeed: Int(Defaults[.courseTableUserRandomSeed]))
        let _start = Date()
        let result = solver.solve()
        let _endDate = Date()
        print("solve cost: \(_endDate.timeIntervalSince(_start)) seconds")

        if result.actualColorPoolSize > colorPool.count {
            if let courseTableView = self.courseTable {
                courseTableView.delegate?.courseTable(courseTableView,
                                                      didDyeWithLargerColorPoolSize: result.actualColorPoolSize,
                                                      currentColorPoolSize: colorPool.count)
            }
        }

        for (class_, course, bgColor) in result.classes {

            let column = courseColumnViews[class_.weekday - 1]

            let cell = PHCTClassCellView()
            classCellViews.append(cell)
            addSubview(cell)
            bringSubviewToFront(cell)

            let startGrid = column.getGridView(lesson: class_.start)
            let endGrid = column.getGridView(lesson: class_.end)
            cell.fixedTo(start: startGrid, end: endGrid)

            cell.delegate = self
            cell.column = column
            cell.model = PHCTClassCellView.CellModel(class: class_, course: course, backgroundColor: bgColor)
            cell.textColor = textColor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func expandedColumn(_ target: PHCTCourseColumnView) {
        guard Defaults[.courseTableCourseColumnExpandable] else { return }
        courseColumnViews.forEach { column in
            column.isExpanded = (column.weekday == target.weekday && !column.isExpanded)
            column.updateConstraints()
        }
    }
}

extension PHCTCourseColumnsScrollView: PHCTCourseColumnViewDelegate {

    func courseColumnDidPress(_ column: PHCTCourseColumnView) {
        expandedColumn(column)
    }
}

extension PHCTCourseColumnsScrollView: PHCTClassCellViewDelegate {

    func classCellDidPress(_ cell: PHCTClassCellView) {
        guard let column = cell.column else { return }
        expandedColumn(column)
    }
}
