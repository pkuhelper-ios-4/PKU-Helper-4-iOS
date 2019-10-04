//
//  PHCTCourseColumnView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/3.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHCTCourseColumnViewDelegate: AnyObject {

    func courseColumnDidPress(_ column: PHCTCourseColumnView)
}

extension PHCTCourseColumnViewDelegate {

    func courseColumnDidPress(_ column: PHCTCourseColumnView) {}
}

class PHCTCourseColumnView: UIView {

    static let normalWidth: CGFloat = PHGlobal.screenWidth / 5.5
    static let expandedWidth: CGFloat = normalWidth * 1.5

    weak var delegate: PHCTCourseColumnViewDelegate?

    var isExpanded: Bool = false

    let headerView = PHCTWeekdayHeaderGridView()
    let courseGridsView = UIStackView(arrangedSubviews: [], axis: .vertical, spacing: 0.0, alignment: .fill, distribution: .fillEqually)

    var weekday: Int? {
        didSet {
            headerView.weekday = weekday
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        for _ in 0..<PHClass.lessonTimes.count {
            let view = PHCTCourseGridView()
            view.column = self
            courseGridsView.addArrangedSubview(view)
        }

        addSubview(headerView)
        addSubview(courseGridsView)

        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        courseGridsView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }

        courseGridsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(courseGridsViewDidTapped)))
    }

    override func updateConstraints() {
        super.updateConstraints()

        self.snp.updateConstraints { make in
            let width = isExpanded ? PHCTCourseColumnView.expandedWidth : PHCTCourseColumnView.normalWidth
            make.width.equalTo(width)
        }
    }

    func getGridView(lesson: Int) -> PHCTCourseGridView {
        return courseGridsView.arrangedSubviews[lesson - 1] as! PHCTCourseGridView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func courseGridsViewDidTapped() {
        delegate?.courseColumnDidPress(self)
    }
}
