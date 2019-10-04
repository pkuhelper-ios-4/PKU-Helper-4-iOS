//
//  PHMessageTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHMessageTableViewCell: UITableViewCell {
    
    static let identifier = "PHMessageTableViewCell"

    let avaterImageView: UIImageView = {
        let view = UIImageView()
        view.image = PHMessageMainViewController.avater
        view.contentMode = .scaleAspectFit
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regularBold
        label.textColor = .black
        label.text = PHMessageMainViewController.sender
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textColor = .darkGray
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()

    var message: PHMessage? {
        didSet {
            guard let message = self.message else { return }
            messageLabel.text = message.content.replacingOccurrences(of: "\n", with: " ")
            timeLabel.text = message.timestamp.secondsToRelativeDate()
            if !message.hasread {
                avaterImageView.pp.addDot(color: .red)
            } else {
                avaterImageView.pp.hiddenBadge()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .white

        contentView.addSubviews([avaterImageView, titleLabel, messageLabel, timeLabel])

        let sideSpacing = PHGlobal.sideSpacing
        let lineSpacing = PHGlobal.font.regular.pointSize * 0.25
        let labelSpacing = PHGlobal.font.regular.pointSize

        avaterImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(sideSpacing)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(lineSpacing * 3)
            make.width.equalTo(avaterImageView.snp.height)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(avaterImageView.snp.right).offset(labelSpacing)
            make.top.equalToSuperview().inset(lineSpacing * 3)
            make.bottom.equalTo(messageLabel.snp.top).offset(-lineSpacing)
        }

        timeLabel.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(labelSpacing)
            make.right.equalToSuperview().inset(sideSpacing)
            make.top.equalToSuperview().inset(lineSpacing * 3)
            make.bottom.equalTo(messageLabel.snp.top).offset(-lineSpacing)
        }

        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(avaterImageView.snp.right).offset(labelSpacing)
            make.right.equalToSuperview().inset(sideSpacing)
            make.bottom.equalToSuperview().inset(lineSpacing * 3)
        }

        avaterImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
