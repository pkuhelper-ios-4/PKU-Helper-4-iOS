//
//  PHCTCustomCoursesTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/20.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHCourseTableCustomCoursesTableViewCellDelegate: AnyObject {

    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressSyncButton button: UIButton)
    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressVisableButton button: UIButton)
//    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressEditButton button: UIButton)
    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressCourseNameLabel label: UILabel)
    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressContentView view: UIView)
}

extension PHCourseTableCustomCoursesTableViewCellDelegate {

    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressSyncButton button: UIButton) {}
    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressVisableButton button: UIButton) {}
//    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressEditButton button: UIButton) {}
    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressCourseNameLabel label: UILabel) {}
    func cell(_ cell: PHCTCustomCoursesTableViewCell, didPressContentView view: UIView) {}
}

class PHCTCustomCoursesTableViewCell: PHCTCourseListBaseTableViewCell {

    override class var identifier: String { return "PHCTCustomCoursesTableViewCell" }

    weak var delegate: PHCourseTableCustomCoursesTableViewCellDelegate?

    let syncButton: UIButton = {
        let button = UIButton()
        let uploadIcon = R.image.cloud_upload()?.scaled(toHeight: iconSideLength)
        let syncIcon = R.image.cloud_sync()?.scaled(toHeight: iconSideLength)
        // cid == nil
        button.setImage(uploadIcon, for: .normal)
        // cid != nil && isSync == false
        button.setImage(syncIcon, for: .highlighted)
        // cid != nil && isSync == true
        button.setImage(syncIcon?.filled(withColor: .blue), for:. disabled)
        return button
    }()

    let visableButton: UIButton = {
        let button = UIButton()
        let visableIcon = R.image.visible()?.scaled(toHeight: iconSideLength)
        let invisableIcon = R.image.invisible()?.scaled(toHeight: iconSideLength)
        button.setImage(invisableIcon, for: .normal)
        button.setImage(visableIcon?.filled(withColor: .blue), for: .highlighted)
        return button
    }()

//    let editButton: UIButton = {
//        let button = UIButton()
//        let icon = R.image.pencil()?.scaled(toHeight: iconSideLength)
//        button.setImage(icon, for: .normal)
//        return button
//    }()

    let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = iconSideLength
        return view
    }()

    override func didUpdateCourse() {
        super.didUpdateCourse()
        guard let course = self.course else { return }
        visableButton.isHighlighted = course.isVisable
        syncButton.isEnabled = !course.isSync
        syncButton.isHighlighted = course.cid != nil && !course.isSync
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubviews([syncButton, visableButton])

        let sideSpacing = PHCTCustomCoursesTableViewCell.sideSpacing
//        let lineSpacing = PHCTCustomCoursesTableViewCell.lineSpacing
        let labelSpacing = PHCTCustomCoursesTableViewCell.labelFont.pointSize

        buttonStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
//            make.centerY.equalToSuperview()
//            make.height.greaterThanOrEqualTo(lineSpacing)
            make.right.equalToSuperview().inset(sideSpacing)
            make.left.equalTo(courseNameLabel.snp.right).offset(labelSpacing)
        }

        courseNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        courseNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        buttonStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        buttonStackView.setContentHuggingPriority(.required, for: .horizontal)
        [syncButton, visableButton].forEach { button in
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.setContentHuggingPriority(.required, for: .horizontal)
        }

        courseNameLabel.isUserInteractionEnabled = true

        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentViewTapped(_:))))
        courseNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(courseNameLabelTapped(_:))))
        syncButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(syncButtonTapped(_:))))
        visableButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(visableButtonTapped(_:))))
//        editButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editButtonTapped(_:))))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    @objc func syncButtonTapped(_ button: UIButton) {
        delegate?.cell(self, didPressSyncButton: button)
    }

    @objc func visableButtonTapped(_ button: UIButton) {
        delegate?.cell(self, didPressVisableButton: button)
    }

//    @objc func editButtonTapped(_ button: UIButton) {
//        delegate?.cell(self, didPressEditButton: _ button)
//    }

    @objc func courseNameLabelTapped(_ label: UILabel) {
        delegate?.cell(self, didPressCourseNameLabel: label)
    }

    @objc func contentViewTapped(_ view: UIView) {
        delegate?.cell(self, didPressContentView: view)
    }
}
