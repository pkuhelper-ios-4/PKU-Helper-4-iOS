//
//  PHIPGWStatusTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHIPGWStatusTableViewCell: UITableViewCell {

    static let identifier = "PHIPGWStatusTableViewCell"

    typealias Model = (title: String, description: String)

    var model: Model? {
        didSet {
            guard let model = self.model else { return }
            textLabel?.text = model.title
            detailTextLabel?.text = model.description
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        textLabel?.font = PHGlobal.font.regular
        detailTextLabel?.font = PHGlobal.font.regular
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
