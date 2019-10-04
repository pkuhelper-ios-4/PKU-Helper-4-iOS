//
//  PHCTCustomCoursesEditingAddClassTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/20.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHCTCustomCoursesEditingAddClassTableViewCell: UITableViewCell {

    static let identifier = "PHCTCustomCoursesEditingAddClassTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        textLabel?.font = PHGlobal.font.regular
        textLabel?.textColor = .lightGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
