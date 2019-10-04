//
//  PHCTCustomCoursesEditingClassTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/20.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHCTCustomCoursesEditingClassTableViewCell: UITableViewCell {

    static let identifier = "PHCTCustomCoursesEditingClassTableViewCell"

    static let labelFont: UIFont = PHGlobal.font.regular
    static let labelHeight: CGFloat = labelFont.pointSize * 2.5
    static let labelSpacing: CGFloat = labelFont.pointSize

    let weekLabel: UILabel = {
        let label = UILabel()
        label.font = labelFont
        return label
    }()

    let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = labelFont
        return label
    }()

    let startLabel: UILabel = {
        let label = UILabel()
        label.font = labelFont
        return label
    }()

    let endLabel: UILabel = {
        let label = UILabel()
        label.font = labelFont
        return label
    }()

    let timeDelimiterLabel: UILabel = {
        let label = UILabel()
        label.text = "~"
        label.font = labelFont
        return label
    }()

    let classroomLabel: UILabel = {
        let label = UILabel()
        label.font = labelFont
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let classTimeStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = labelFont.pointSize * 0.25
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        return view
    }()

    var `class`: PHClass? {
        didSet {
            guard let class_ = self.`class` else { return }
            weekLabel.text = class_.week.displayName
            weekdayLabel.text = PHClass.getWeekdayName(class_.weekday)
            startLabel.text = String(class_.start)
            endLabel.text = String(class_.end)
            classroomLabel.text = class_.classroom
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        let sideSpacing = PHCTCustomCoursesEditingBaseViewController.sideSpacing
        let labelFont = PHCTCustomCoursesEditingClassTableViewCell.labelFont
        let labelHeight = PHCTCustomCoursesEditingClassTableViewCell.labelHeight
        let labelSpacing = PHCTCustomCoursesEditingClassTableViewCell.labelSpacing

        classTimeStackView.addArrangedSubviews([startLabel, timeDelimiterLabel, endLabel])
        contentView.addSubviews([weekLabel, weekdayLabel, classTimeStackView, classroomLabel])

        weekLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(labelHeight)
            make.width.equalTo(labelFont.pointSize * 2.25 + labelSpacing)
            make.left.equalToSuperview().inset(sideSpacing)
        }

        weekdayLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(labelHeight)
            make.width.equalTo(labelFont.pointSize * 1.25 + labelSpacing)
            make.left.equalTo(weekLabel.snp.right).offset(labelSpacing)
        }

        classTimeStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(labelHeight)
            make.width.lessThanOrEqualTo(labelFont.pointSize * 2.5 + labelSpacing)
            make.left.equalTo(weekdayLabel.snp.right).offset(labelSpacing)
        }

        classroomLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(labelHeight)
            make.right.lessThanOrEqualToSuperview().inset(sideSpacing)
            make.left.equalTo(classTimeStackView.snp.left).offset(labelFont.pointSize * 3.25 + labelSpacing)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.`class` = nil
    }
}
