//
//  PHScoreTableViewFooterView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHScoreTableViewFooterView: UITableViewHeaderFooterView {

    static let identifier = "PHScoreTableViewFooterView"

    static let topInset = PHScoreTableViewHeaderView.bottomInset
    static let bottomInset = PHScoreTableViewHeaderView.topInset

    let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regular
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(summaryLabel)

        let sideSpacing = PHScoreMainViewController.sideSpacing
        let topInset = PHScoreTableViewFooterView.topInset
        let bottomInset = PHScoreTableViewFooterView.bottomInset

        summaryLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(sideSpacing)
            make.left.greaterThanOrEqualToSuperview().inset(sideSpacing)
            make.top.equalToSuperview().inset(topInset)
            make.bottom.equalToSuperview().inset(bottomInset)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
