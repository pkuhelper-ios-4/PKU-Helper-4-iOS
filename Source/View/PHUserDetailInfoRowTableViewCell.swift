//
//  PHUserDetailInfoRowTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/14.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHUserDetailInfoRowTableViewCell: UITableViewCell {

    static let identifier = "PHUserDetailInfoRowTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        textLabel?.font = PHGlobal.font.regular
        detailTextLabel?.font = PHGlobal.font.regular
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.removeGestureRecognizers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
