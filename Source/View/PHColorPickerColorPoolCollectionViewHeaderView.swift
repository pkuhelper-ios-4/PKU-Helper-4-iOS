//
//  PHColorPickerColorPoolCollectionViewHeaderView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/10/2.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHColorPickerColorPoolCollectionViewHeaderView: UICollectionReusableView {

    static let identifier = "PHColorPickerColorPoolCollectionViewHeaderView"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regular
        label.textColor = .lightGray
        return label
    }()

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(titleLabel)

        let itemSideLength = PHBaseColorPicker.itemSideLength
        let percent = PHColorPickerBaseCircleCollectionViewCell.circleDiameterPercent

        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset( itemSideLength * (1 - CGFloat(percent)) / 2 )
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
