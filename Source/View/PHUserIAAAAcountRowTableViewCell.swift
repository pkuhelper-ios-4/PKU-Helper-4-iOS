//
//  PHUserIAAAAcountRowTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHUserIAAAAcountRowTableViewCell: UITableViewCell {

    static let identifier = "PHUserIAAAAcountRowTableViewCell"

    let secureIconImageView: UIImageView = {
        let diameter = PHGlobal.font.huge.pointSize
        let view = UIImageView(frame: CGRect(origin: .zero, size: CGSize(side: diameter)))
        view.image = R.image.security_checked()?.template
        view.tintColor = Color.Material.greenA700
        view.contentMode = .scaleAspectFit
        return view
    }()

    var hasPasswordStored: Bool = false {
        didSet {
            guard oldValue != hasPasswordStored else { return }
            accessoryView = hasPasswordStored ? secureIconImageView : nil
            debugPrint(accessoryType)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator // default view
        backgroundColor = .white

        textLabel?.font = PHGlobal.font.regular
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.removeGestureRecognizers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
