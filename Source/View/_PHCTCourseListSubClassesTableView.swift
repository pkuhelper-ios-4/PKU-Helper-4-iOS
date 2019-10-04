//
//  PHCTCourseListSubClassesTableView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/22.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit

class PHCTCourseListSubClassesTableView: UITableView {

    var course: PHCourse? {
        didSet {
            guard let _ = course else { return }
            reloadData()
        }
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: .plain)
        register(PHCTCourseListSubClassesTableViewCell.self, forCellReuseIdentifier: PHCTCourseListSubClassesTableViewCell.identifier)

        allowsSelection = false
        allowsMultipleSelection = false

        showsVerticalScrollIndicator = false
        bounces = false

        separatorStyle = .singleLine
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfRows(inSection section: Int) -> Int {
        return course?.classes.count ?? 0
    }

    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        guard let course = self.course else { return nil }
        let cell = dequeueReusableCell(withIdentifier: PHCTCourseListSubClassesTableViewCell.identifier, for: indexPath) as! PHCTCourseListSubClassesTableViewCell
        let class_ = course.classes[indexPath.row]
        cell.`class` = class_
        return cell
    }
}
**/
