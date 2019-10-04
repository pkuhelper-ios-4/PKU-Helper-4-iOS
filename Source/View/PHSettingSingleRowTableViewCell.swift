//
//  PHSettingSingleRowTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHSettingSingleRowTableViewCell: UITableViewCell {

    class var identifier: String { return "PHSettingSingleRowTableViewCell" }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator
        backgroundColor = .white

        textLabel?.font = PHGlobal.font.regular
        textLabel?.textColor = .black
        textLabel?.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        contentView.removeGestureRecognizers()
        accessoryView = nil
    }
}
