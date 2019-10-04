//
//  PHHoleDetailTableViewHeaderView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/25.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHHoleDetailTableViewHeaderView: UITableViewHeaderFooterView {

    static let identifier = "PHHoleDetailTableViewHeaderView"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.small
        label.textColor = .gray
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let sideSpacing = PHHoleBaseTableViewCell.sideSpacing

        contentView.addSubview(titleLabel)

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
