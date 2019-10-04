//
//  PHMainUserView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHMainUserViewDelegate: AnyObject {

    func userView(_ userView: PHMainUserView, didPressAvaterImageView avaterImageView: UIImageView)
    func userView(_ userView: PHMainUserView, didPressNameLabel nameLabel: UILabel)
    func userView(_ userView: PHMainUserView, didPressDepartmentLabel departmentLabel: UILabel)
}

extension PHMainUserViewDelegate {

    func userView(_ userView: PHMainUserView, didPressAvaterImageView avaterImageView: UIImageView) {}
    func userView(_ userView: PHMainUserView, didPressNameLabel nameLabel: UILabel) {}
    func userView(_ userView: PHMainUserView, didPressDepartmentLabel departmentLabel: UILabel) {}
}

class PHMainUserView: UIView {

    static let topSpacing = PHGlobal.font.regular.pointSize * 4
    static let bottomSpacing = PHGlobal.font.regular.pointSize * 3
    static let avaterDiameter = PHGlobal.font.regular.pointSize * 3.5
    static let labelSpacing = PHGlobal.font.regular.pointSize * 0.5

    weak var delegate: PHMainUserViewDelegate?

    let avaterImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = PHGlobal.font.regularBold
        label.isUserInteractionEnabled = true
        return label
    }()

    let departmentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = PHGlobal.font.tiny
        label.isUserInteractionEnabled = true
        return label
    }()

    var user: PHUser? {
        didSet {
            if let user = user {
                switch user.gender {
                case .male:
                    avaterImageView.image = R.image.user_male()
                case .female:
                    avaterImageView.image = R.image.user_female()
                default:
                    avaterImageView.image = R.image.user_male()
                }
                nameLabel.text = user.name
                departmentLabel.text = user.department
            } else {
                avaterImageView.image = R.image.user_male()
                nameLabel.text = "Alice"
                departmentLabel.text = "Not logged in"
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubviews([avaterImageView, nameLabel, departmentLabel])

        let topSpacing = PHMainUserView.topSpacing
        let bottomSpacing = PHMainUserView.bottomSpacing
        let avaterDiameter = PHMainUserView.avaterDiameter
        let labelSpacing = PHMainUserView.labelSpacing

        avaterImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(topSpacing)
            make.width.height.equalTo(avaterDiameter)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avaterImageView.snp.bottom).offset(labelSpacing * 3)
        }

        departmentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(labelSpacing)
            make.bottom.equalToSuperview().inset(bottomSpacing)
        }

        avaterImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressAvatar)))
        nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressNameLabel)))
        departmentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressDepartmentLabel)))

        user = nil // trigger didSet to setup default value
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didPressAvatar() {
        delegate?.userView(self, didPressAvaterImageView: avaterImageView)
    }

    @objc func didPressNameLabel() {
        delegate?.userView(self, didPressNameLabel: nameLabel)
    }

    @objc func didPressDepartmentLabel() {
        delegate?.userView(self, didPressDepartmentLabel: departmentLabel)
    }
}

