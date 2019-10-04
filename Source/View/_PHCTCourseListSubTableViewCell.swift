//
//  PHCTCourseListSubTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/22.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit

class PHCTCourseListSubTableViewCell: PHCTCourseListBaseTableViewCell {

    override class var identifier: String { return "PHCTCourseListSubTableViewCell" }

    let classesSubTableView = PHCTCourseListSubClassesTableView()

    weak var courseCell: PHCTCourseListBaseTableViewCell? {
        didSet {
            classesSubTableView.course = courseCell?.course
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        classesSubTableView.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        courseCell = nil
    }
}

extension PHCTCourseListSubTableViewCell: UITableViewDelegate {

}
**/
