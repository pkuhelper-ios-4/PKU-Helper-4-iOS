//
//  PHSettingThemeTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHSettingThemeTableViewCell: UITableViewCell {
    
    static let identifier = "PHSettingThemeTableViewCell"
    
    var theme: PHTheme? {
        didSet {
            guard let theme = theme else { return }
            textLabel?.text = theme.rawValue
            imageView?.image = UIImage(color: theme.mainColor, size: CGSize(width: 20, height: 20)).rounded()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        accessoryType = .none
//        backgroundColor = .white
//        textLabel?.textColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
