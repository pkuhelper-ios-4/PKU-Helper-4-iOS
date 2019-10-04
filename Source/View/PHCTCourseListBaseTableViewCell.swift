//
//  PHCTCourseListBaseTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/22.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
//
//protocol PHCTCourseListBaseTableViewCellDelegate: AnyObject {
//
//    func cellDidPressContentView(_ cell: PHCTCourseListBaseTableViewCell)
//}
//
//extension PHCTCourseListBaseTableViewCellDelegate {
//
//    func cellDidPressContentView(_ cell: PHCTCourseListBaseTableViewCell) {}
//}

class PHCTCourseListBaseTableViewCell: UITableViewCell {

    class var identifier: String { return "PHCTCourseListBaseTableViewCell" }

//    weak var delegate: PHCTCourseListBaseTableViewCellDelegate?

    static let sideSpacing: CGFloat = PHGlobal.sideSpacing
    static let labelFont: UIFont = PHGlobal.font.regular
    static let lineSpacing: CGFloat = labelFont.pointSize
    static let iconSideLength: CGFloat = PHGlobal.font.huge.pointSize

    let courseNameLabel: UILabel = {
        let label = UILabel()
        label.font = PHCTCourseListBaseTableViewCell.labelFont
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    var course: PHCourse? {
        didSet {
            didUpdateCourse()
        }
    }

    func didUpdateCourse() {
        guard let course = course else { return }
        courseNameLabel.text = course.name
//        subClassesCell?.course = course
    }

//    weak var subClassesCell: PHCTCourseListSubTableViewCell? {
//        didSet {
//            subClassesCell?.courseCell = self
//        }
//    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(courseNameLabel)

        let sideSpacing = PHCTCustomCoursesTableViewCell.sideSpacing
        let lineSpacing = PHCTCustomCoursesTableViewCell.lineSpacing

        courseNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.greaterThanOrEqualTo(lineSpacing)
            make.left.equalToSuperview().inset(sideSpacing)
        }

//        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellContentViewDidTapped(_:))))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
//        delegate = nil
        course = nil
//        subClassesCell?.courseCell = nil
//        subClassesCell = nil
    }

//    @objc func cellContentViewDidTapped(_ gesture: UIGestureRecognizer) {
//        debugPrint("cell contentView tapped")
////        delegate?.cellDidPressContentView(self)
//    }
}

