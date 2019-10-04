//
//  PHCTSideColumnView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/3.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class PHCTSideColumnView: UIView {

    var isShowClassTime: Bool = Defaults[.courseTableDefaultExpandedSideColumn]

    let headerView = PHCTWeekdayHeaderGridView()
    let sideGridsView = UIStackView(arrangedSubviews: [], axis: .vertical, spacing: 0.0, alignment: .fill, distribution: .fillEqually)

    override init(frame: CGRect) {
        super.init(frame: frame)

        for courseNumber in 1...PHClass.lessonTimes.count {
            let view = PHCTSideGridView()
            view.column = self
            view.classNumber = courseNumber
            sideGridsView.addArrangedSubview(view)
        }

        addSubviews([headerView, sideGridsView])

        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        sideGridsView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }

        headerView.isDummy = true
        sideGridsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sideGridsTapped)))
    }
    
    @objc func sideGridsTapped() {
        isShowClassTime.toggle()
        updateConstraints()
    }

    override func updateConstraints() {
        super.updateConstraints()
        sideGridsView.arrangedSubviews.forEach { $0.updateConstraints() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
