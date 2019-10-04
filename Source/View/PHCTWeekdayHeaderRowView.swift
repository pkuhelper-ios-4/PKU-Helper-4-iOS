//
//  PHCTWeekdayHeaderRowView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/14.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class PHCTWeekdayHeaderRowView: UIView {

    var isShowDate: Bool = Defaults[.courseTableDefaultExpandedWeekdayHeader]

    var weekdayGrids: [PHCTWeekdayHeaderGridView] = [] {
        didSet {
            weekdayGrids.forEach { grid in
                grid.row = self
                if !grid.isDummy {
                    grid.removeGestureRecognizers()
                    grid.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerGridTapped)))
                }
            }
        }
    }

    @objc func headerGridTapped() {
        isShowDate.toggle()
        updateConstraints()
    }

    override func updateConstraints() {
        super.updateConstraints()
        weekdayGrids.forEach { $0.updateConstraints() }
    }
}
