//
//  PHSettingDualRowTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHSettingDualRowTableViewCell: UITableViewCell {

    static let identifier = "PHSettingDualRowTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        accessoryType = .none
        backgroundColor = .white

        textLabel?.font = PHGlobal.font.regular
        textLabel?.textColor = .black

        detailTextLabel?.font = PHGlobal.font.tiny
        detailTextLabel?.textColor = .black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        contentView.removeGestureRecognizers()
    }
}
