//
//  PHCTClassCellView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/3.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

protocol PHCTClassCellViewDelegate: AnyObject {

    func classCellDidPress(_ cell: PHCTClassCellView)
}

extension PHCTClassCellViewDelegate {

    func classCellDidPress(_ cell: PHCTClassCellView) {}
}

class PHCTClassCellView: UIView {

    static let edgeSpacing: CGFloat = 4

    static let defaultTextColor = UIColor.Material.grey100
    static let defaultColorForHiddenClass = UIColor.Material.grey300
    static let defaultColorPool = [
        UIColor.Material.blue300,
        UIColor.Material.cyan400,
        UIColor.Material.purple200,
        UIColor.Material.green300,
        UIColor.Material.amber600,
        UIColor.Material.deepOrange300,
    ]

    weak var delegate: PHCTClassCellViewDelegate?

    let courseNameLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.smallBold
        label.textAlignment = .center
        label.numberOfLines = 0 // multi-line
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let classroomLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textAlignment = .center
        return label
    }()

    let weekLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textAlignment = .center
        return label
    }()

    let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = PHGlobal.font.small.pointSize * 0.3
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()

    weak var column: PHCTCourseColumnView?

    var textColor: UIColor! {
        didSet {
            courseNameLabel.textColor = textColor
            classroomLabel.textColor = textColor
            weekLabel.textColor = textColor
        }
    }

    var model: CellModel! {
        didSet {
            courseNameLabel.text = model.course.name
            classroomLabel.text = model.class.classroom
            weekLabel.text = (model.class.week == .every) ? nil : "(\(model.class.week.displayName))"
            backgroundColor = model.backgroundColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(contentStackView)
        contentStackView.addArrangedSubviews([courseNameLabel, classroomLabel, weekLabel])

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellDidTapped)))
    }

    override func updateConstraints() {
        super.updateConstraints()
        let edgeSpacing = PHCTClassCellView.edgeSpacing
        contentStackView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().inset(edgeSpacing * 0.5)
            make.bottom.lessThanOrEqualToSuperview().inset(edgeSpacing * 0.5)
            make.left.right.equalToSuperview().inset(edgeSpacing)
            make.centerY.equalToSuperview()
        }
    }

    func fixedTo(start startGrid: PHCTCourseGridView, end endGrid: PHCTCourseGridView) {
        self.snp.makeConstraints { make in
            make.left.top.equalTo(startGrid)
            make.right.bottom.equalTo(endGrid)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func cellDidTapped() {
        delegate?.classCellDidPress(self)
    }
}

extension PHCTClassCellView {

    struct CellModel {

        let `class`: PHClass
        let course: PHCourse
        let backgroundColor: UIColor?

        init(`class`: PHClass, course: PHCourse, backgroundColor: UIColor?) {
            self.`class` = `class`
            self.course = course
            self.backgroundColor = backgroundColor
        }
    }
}
