//
//  PHMyPKUCollectionViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/9.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit

class PHMyPKUCollectionViewCell: UICollectionViewCell {

    static let identifier = "PHMyPKUCollectionViewCell"

    static let cellInsetSpacing: CGFloat = PHGlobal.sideSpacing

    let iconImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = PHGlobal.font.smallBold
        label.textColor = .black
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    var id: Int!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let insetSpacing = PHMyPKUCollectionViewCell.cellInsetSpacing

        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1

        contentView.addSubviews([iconImageView, titleLabel])
        
        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(iconImageView.snp.height).priority(.high)
            make.top.equalToSuperview().inset(insetSpacing)
            make.left.right.equalToSuperview().inset(insetSpacing)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(insetSpacing)
            make.bottom.equalToSuperview().inset(insetSpacing)
            make.left.right.equalToSuperview().inset(insetSpacing / 2)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.removeGestureRecognizers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
**/
