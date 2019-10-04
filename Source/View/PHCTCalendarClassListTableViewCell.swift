//
//  PHCTCalendarClassListTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import EventKit
import SwiftDate

class PHCTCalendarClassListTableViewCell: UITableViewCell {

    static let identifier = "PHCTCalendarClassListTableViewCell"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regularBold
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let siteLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let startDateLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textColor = .black
        return label
    }()

    let endDateLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textColor = .black
        return label
    }()

    let dateDelimiterLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textColor = .black
        label.text = "-"
        return label
    }()

    let dateStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        return view
    }()

    var event: EKEvent? {
        didSet {
            guard let event = self.event else { return }
            titleLabel.text = event.title
            siteLabel.text = event.location
            startDateLabel.text = event.startDate.timeIntervalSince1970.formatTimestamp(to: "E, MM/dd/yy  HH:mm")
            endDateLabel.text = event.endDate.timeIntervalSince1970.formatTimestamp(to: "HH:mm")
            // don't use date.toFormat(), or the timeZone will always be incorrect :(
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        dateStackView.addArrangedSubviews([startDateLabel, dateDelimiterLabel, endDateLabel])
        contentView.addSubviews([titleLabel, dateStackView, siteLabel])

        let sideSpacing = PHGlobal.sideSpacing
        let labelSpacing = PHGlobal.font.regular.pointSize
        let lineSpacing = PHGlobal.font.regular.pointSize * 0.5

        dateStackView.spacing = PHGlobal.font.tiny.pointSize * 0.25

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.equalToSuperview().inset(lineSpacing)
        }

        siteLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(sideSpacing)
            make.bottom.equalToSuperview().inset(lineSpacing)
            make.top.equalTo(titleLabel.snp.bottom).offset(lineSpacing)
        }

        dateStackView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(sideSpacing)
            make.bottom.equalToSuperview().inset(lineSpacing)
            make.top.equalTo(titleLabel.snp.bottom).offset(lineSpacing)
            make.left.equalTo(siteLabel.snp.right).offset(labelSpacing)
        }

        siteLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        siteLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        dateStackView.setContentHuggingPriority(.required, for: .horizontal)
        dateStackView.arrangedSubviews.forEach { view in
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            view.setContentHuggingPriority(.required, for: .horizontal)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
