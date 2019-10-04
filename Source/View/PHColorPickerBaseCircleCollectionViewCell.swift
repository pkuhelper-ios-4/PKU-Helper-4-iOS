//
//  PHColorPickerBaseCircleCollectionViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/10/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHColorPickerBaseCircleCollectionViewCell: UICollectionViewCell {

    class var identifier: String { return "PHColorPickerBaseCircleCollectionViewCell" }
    static let circleDiameterPercent = 0.75

    let contentImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    var image: UIImage? {
        didSet {
            contentImageView.image = image
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        //
        // https://www.hangge.com/blog/cache/detail_1436.html
        //
        backgroundColor = .clear

        contentView.addSubview(contentImageView)

        let percent = PHColorPickerBaseCircleCollectionViewCell.circleDiameterPercent

        contentImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(percent)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
