//
//  PHMessageDetailView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/14.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHMessageDetailView: UIView {

    let headerView: UIView = {
        let view = UIView()
        return view
    }()

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
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textColor = .lightGray
        return label
    }()

    let idLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textColor = .lightGray
        return label
    }()

    let messageTextView: UITextView = {
        let view = UITextView()
        view.font = PHGlobal.font.small
        view.isEditable = false
        return view
    }()

    var message: PHMessage? {
        didSet {
            guard let message = self.message else { return }
            idLabel.text = "#\(message.mid)"
            timeLabel.text = TimeInterval(message.timestamp).formatTimestamp()
            messageTextView.text = message.content
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        headerView.addSubviews([avaterImageView, titleLabel, timeLabel, idLabel])
        addSubviews([headerView, messageTextView])

        let sideSpacing = PHGlobal.sideSpacing
        let headerTopSpacing = PHGlobal.font.regular.pointSize * 1.5
        let headerButtonSpacing = PHGlobal.font.regular.pointSize * 2
        let labelSpacing = PHGlobal.font.regular.pointSize
        let lineSpacing = PHGlobal.font.regular.pointSize * 0.5

        messageTextView.textContainerInset = UIEdgeInsets(px: sideSpacing, py: lineSpacing * 2)

        headerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }

        messageTextView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }

        avaterImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(sideSpacing)
            make.top.equalToSuperview().inset(headerTopSpacing)
            make.bottom.equalToSuperview().inset(headerButtonSpacing)
            make.width.equalTo(avaterImageView.snp.height)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(avaterImageView.snp.right).offset(labelSpacing)
            make.top.equalToSuperview().inset(headerTopSpacing)
            make.bottom.equalTo(timeLabel.snp.top).offset(-lineSpacing)
        }

        idLabel.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(labelSpacing)
            make.right.equalToSuperview().inset(sideSpacing)
            make.top.equalToSuperview().inset(headerTopSpacing)
            make.bottom.equalTo(timeLabel.snp.top).offset(-lineSpacing)
        }

        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(avaterImageView.snp.right).offset(labelSpacing)
            make.right.equalToSuperview().inset(sideSpacing)
            make.bottom.equalToSuperview().inset(headerButtonSpacing)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
