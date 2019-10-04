//
//  PHCTSideGridView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/3.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHCTSideGridView: UIView {

    static let edgeSpacing: CGFloat = 5
    static let labelSpacing: CGFloat = PHGlobal.font.regular.pointSize * 0.3

    weak var column: PHCTSideColumnView?

    let classNumberLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regularBold
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    let classTimeLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.smallest
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    var classNumber: Int! {
        didSet {
            classNumberLabel.text = String(classNumber)
            let (start, end) = PHClass.lessonTimes[classNumber - 1]
            classTimeLabel.text = "\(start)-\(end)"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(classNumberLabel)

        let edgeSpacing = PHCTSideGridView.edgeSpacing
        classNumberLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(edgeSpacing)
            make.centerY.equalToSuperview().priority(.low)
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        guard let column = self.column else { return }
        if column.isShowClassTime {
            addSubview(classTimeLabel)
            let edgeSpacing = PHCTSideGridView.edgeSpacing
            let labelSpacing = PHCTSideGridView.labelSpacing
            let offsetY = PHGlobal.font.regular.pointSize * 0.8
            classTimeLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(edgeSpacing)
                make.centerY.equalToSuperview().offset(offsetY).priority(.high)
                make.top.equalTo(classNumberLabel.snp.bottom).offset(labelSpacing).priority(.high)
            }
        } else {
            classTimeLabel.removeFromSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
