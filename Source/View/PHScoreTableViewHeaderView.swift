//
//  PHScoreTableViewHeaderView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHScoreTableViewHeaderView: UITableViewHeaderFooterView {

    static let identifier = "PHScoreTableViewHeaderView"

    static let topInset = PHGlobal.font.regular.pointSize * 3
    static let bottomInset = PHGlobal.font.regular.pointSize * 1.5

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.largeBold
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)

        let topInset = PHScoreTableViewHeaderView.topInset
        let bottomInset = PHScoreTableViewHeaderView.bottomInset

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(topInset)
            make.bottom.equalToSuperview().inset(bottomInset)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
