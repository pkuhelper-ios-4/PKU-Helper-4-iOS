//
//  PHIPGWConnectionTableViewCell.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHIPGWConnectionTableViewCell: UITableViewCell {

    static let identifier = "PHIPGWConnectionTableViewCell"

    let starLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regularBold
        label.textColor = .black
        label.text = "☆"
        return label
    }()

    let ipLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regularBold
        label.textColor = .black
        return label
    }()

    let typeLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        label.textColor = .black
        return label
    }()

    let siteLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.tiny
        return label
    }()

    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regular
        label.textColor = .black
        label.lineBreakMode = .byTruncatingHead
        return label
    }()

    let leftIPLabelStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        return view
    }()

    let leftDetailStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        return view
    }()

    let leftStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .leading
        return view
    }()

    var currentStatus: PHIPGWStatus?

    var connection: PHIPGWConnection? {
        didSet {
            guard let connection = self.connection else { return }
            ipLabel.text = connection.ip
            siteLabel.text = connection.site
            typeLabel.text = connection.type
            timestampLabel.text = connection.timestamp.formatTimestamp()

            starLabel.isHidden = !(currentStatus?.ip == connection.ip)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        leftIPLabelStackView.addArrangedSubviews([starLabel, ipLabel])
        leftDetailStackView.addArrangedSubviews([typeLabel, siteLabel])
        leftStackView.addArrangedSubviews([leftIPLabelStackView, leftDetailStackView])
        contentView.addSubviews([leftStackView, timestampLabel])

        let sideSpacing = PHGlobal.sideSpacing
        let labelSpacing = PHGlobal.font.regular.pointSize
        let lineSpacing = PHGlobal.font.regular.pointSize * 0.5

        leftIPLabelStackView.spacing = labelSpacing * 0.5
        leftDetailStackView.spacing = labelSpacing * 0.5
        leftStackView.spacing = lineSpacing

        leftStackView.snp.makeConstraints { make in
            make.top.bottom.centerY.equalToSuperview().inset(lineSpacing)
            make.left.equalToSuperview().inset(sideSpacing)
        }

        timestampLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(sideSpacing)
            make.left.greaterThanOrEqualTo(leftStackView.snp.right).offset(labelSpacing)
        }

        timestampLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        starLabel.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        starLabel.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
