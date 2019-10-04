//
//  PHUserButtonRowTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/14.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHUserButtonRowTableViewCell: UITableViewCell {

    static let identifier = "PHUserButtonRowTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        accessoryType = .none

        textLabel?.center = contentView.center
        textLabel?.textAlignment = .center
        textLabel?.font = PHGlobal.font.regularBold

        backgroundColor = .white
        textLabel?.textColor = .red
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.removeGestureRecognizers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
