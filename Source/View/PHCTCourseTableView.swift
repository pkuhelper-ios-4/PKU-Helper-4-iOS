//
//  PHCTCourseTableView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHCTCourseTableViewDelegate: AnyObject {

    func courseTable(_ view: PHCTCourseTableView, didDyeWithLargerColorPoolSize actualColorPoolSize: Int, currentColorPoolSize: Int)
}

extension PHCTCourseTableViewDelegate {

    func courseTable(_ view: PHCTCourseTableView, didDyeWithLargerColorPoolSize actualColorPoolSize: Int, currentColorPoolSize: Int) {}
}

class PHCTCourseTableView: UIView {

    static let weekdays: Int = 7

    weak var delegate: PHCTCourseTableViewDelegate?

    let headerRowView = PHCTWeekdayHeaderRowView() // This row view is actually not visable
    let sideColumnView = PHCTSideColumnView()
    let courseColumnsScrollView = PHCTCourseColumnsScrollView()

    var courses: [PHCourse]? {
        didSet {
            courseColumnsScrollView.setupClassCells()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        courseColumnsScrollView.courseTable = self

        addSubviews([headerRowView, sideColumnView, courseColumnsScrollView])

        sideColumnView.snp.makeConstraints { make in
            make.top.equalTo(PHGlobal.topBarsHeight)
            make.left.bottom.equalToSuperview()
        }
        courseColumnsScrollView.snp.makeConstraints { make in
            make.top.equalTo(PHGlobal.topBarsHeight)
            make.right.bottom.equalToSuperview()
            make.left.equalTo(sideColumnView.snp.right)
        }

        // header row must be setup at last
        headerRowView.weekdayGrids = [sideColumnView.headerView] + courseColumnsScrollView.courseColumnViews.map { $0.headerView }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
