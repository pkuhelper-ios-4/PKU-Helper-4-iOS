//
//  PHCTWeekdayHeaderGridView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/3.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftDate

class PHCTWeekdayHeaderGridView: UIView {

    static let labelSpacing = PHGlobal.font.small.pointSize * 0.3

    weak var row: PHCTWeekdayHeaderRowView?

    let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.smallBold
        label.backgroundColor = .clear
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.smallest
        label.backgroundColor = .clear
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    var weekday: Int? {
        didSet {
            guard let weekday = self.weekday else { return }
            let startDate = PHGlobal.regionBJ.nowInThisRegion().startOfWeekFromMonday
            let date = startDate + (weekday - 1).days // weekday -> [1, 7]

            weekdayLabel.text = date.weekdayName(.short)
            dateLabel.text = date.toFormat("MM-dd")
        }
    }

    // The first header above the side column
    var isDummy: Bool = false {
        didSet {
            if isDummy {
                weekdayLabel.isHidden = true
                dateLabel.isHidden = true
                weekday = 1 // set a random week
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(weekdayLabel)
        
        let spacing = PHCTWeekdayHeaderGridView.labelSpacing
        weekdayLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(spacing)
            make.bottom.equalToSuperview().inset(spacing).priority(.low)
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        guard let row = self.row else { return }
        if row.isShowDate {
            addSubview(dateLabel)
            let spacing = PHCTWeekdayHeaderGridView.labelSpacing
            dateLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(spacing)
                make.top.equalTo(weekdayLabel.snp.bottom).inset(-spacing).priority(.high)
            }
        } else {
            dateLabel.removeFromSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
