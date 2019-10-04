//
//  PHMainStatusCellView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHMainStatusCellView: UIView {

    let countLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regular
        label.textAlignment = .center
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    var id: Int!

    typealias CellModel = (id: Int, count: Double, description: String)

    var model: CellModel? {
        didSet {
            guard let model = model else { return }
            id = model.id
            countLabel.text = model.count.format("%g")
            descriptionLabel.text = model.description
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let lineSpacing = PHGlobal.font.regular.pointSize * 0.5
//        let maxNumberOfCells = PHMainStatusView.maxNumberOfCells

        addSubviews([countLabel, descriptionLabel])

        countLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(lineSpacing * 2)
        }

        descriptionLabel.snp.makeConstraints { make in
//            let labelAdditionalInset = PHGlobal.screenWidth / CGFloat(maxNumberOfCells) * 0.05
//            make.left.right.equalToSuperview().inset(labelAdditionalInset)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(lineSpacing * 1.5)
            make.top.equalTo(countLabel.snp.bottom).offset(lineSpacing)
        }

        countLabel.setContentHuggingPriority(.required, for: .vertical)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("deinit \(NSStringFromClass(type(of: self)))")
    }
}
