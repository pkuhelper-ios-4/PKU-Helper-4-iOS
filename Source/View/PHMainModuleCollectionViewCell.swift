//
//  PHMainModuleCollectionViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHMainModuleCollectionViewCell: UICollectionViewCell {

    static let identifier = "PHMainModuleCollectionViewCell"

    let iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.alignment = .center
        view.spacing = PHGlobal.font.regular.pointSize * 0.8
        return view
    }()

    var id: Int!

    typealias CellModel = (id: Int, title: String, icon: UIImage)

    var model: CellModel? {
        didSet {
            guard let model = self.model else { return }
            id = model.id
            titleLabel.text = model.title
            iconImageView.image = model.icon
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        contentStackView.addArrangedSubviews([iconImageView, titleLabel])
        contentView.addSubview(contentStackView)

        contentStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            let factor = Double(PHMainModuleView.numberOfItemsInRow) * 3
            make.width.height.equalTo(PHGlobal.screenWidth / CGFloat(factor))
        }
    }

    override func prepareForReuse() {
        contentView.removeGestureRecognizers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
