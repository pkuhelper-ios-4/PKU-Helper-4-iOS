//
//  PHCTCustomCoursesEditingClassTableViewHeaderView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/20.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHCTCustomCoursesEditingClassTableViewHeaderView: UITableViewHeaderFooterView {

    static let identifier = "PHCTCustomCoursesEditingClassTableViewHeaderView"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.small
        label.textColor = .lightGray
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let sideSpacing = PHCTCustomCoursesEditingBaseViewController.sideSpacing

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
