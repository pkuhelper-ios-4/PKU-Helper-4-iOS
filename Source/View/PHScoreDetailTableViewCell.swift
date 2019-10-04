//
//  PHScoreDetailTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHScoreDetailTableViewCell: UITableViewCell {
    
    static let identifier = "PHScoreDetailTableViewCell"
    
    typealias RowEntry = (String, String?)
    
    var entry: RowEntry? {
        didSet {
            guard let entry = self.entry else { return }
            textLabel?.text = entry.0
            detailTextLabel?.text = entry.1
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
