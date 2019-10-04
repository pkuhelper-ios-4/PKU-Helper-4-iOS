//
//  PHSettingUserRowTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit
import SnapKit

class PHSettingUserRowTableViewCell: UITableViewCell {

    static let identifier = "PHSettingUserRowTableViewCell"

    var user: PHUser? {
        didSet {
            if let user = self.user {
                textLabel?.text = user.name
                detailTextLabel?.text = user.department
                switch user.gender {
                case .male:
                    imageView?.image = R.image.user_male()
                case .female:
                    imageView?.image = R.image.user_female()
                case .unknown:
                    imageView?.image = R.image.user_male()
                }
            } else {
                textLabel?.text = "Alice"
                detailTextLabel?.text = "Unknown"
                imageView?.image = R.image.user_male()
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        accessoryType = .none
        backgroundColor = .white

        textLabel?.font = PHGlobal.font.regularBold
        textLabel?.textColor = .black

        detailTextLabel?.font = PHGlobal.font.tiny
        detailTextLabel?.textColor = .black
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let imageView = self.imageView else { return }
        imageView.contentMode = .scaleAspectFit
        let center = imageView.center
        imageView.frame = CGRect(origin: imageView.frame.origin, size: CGSize(side: PHGlobal.font.regular.pointSize * 2.5))
        imageView.center = center
    }

    override func prepareForReuse() {
        contentView.removeGestureRecognizers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
**/
