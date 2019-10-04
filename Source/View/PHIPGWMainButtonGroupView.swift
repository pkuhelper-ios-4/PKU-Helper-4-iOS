//
//  PHIPGWMainButtonGroupView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHIPGWMainButtonGroupViewDelegate: AnyObject {

    func buttonGroups(_ view: PHIPGWMainButtonGroupView, didPressConnectButton button: UIButton)
    func buttonGroups(_ view: PHIPGWMainButtonGroupView, didPressDisconnectButton button: UIButton)
    func buttonGroups(_ view: PHIPGWMainButtonGroupView, didPressDisconnectAllButton button: UIButton)
}

extension PHIPGWMainButtonGroupViewDelegate {

    func buttonGroups(_ view: PHIPGWMainButtonGroupView, didPressConnectButton button: UIButton) {}
    func buttonGroups(_ view: PHIPGWMainButtonGroupView, didPressDisconnectButton button: UIButton) {}
    func buttonGroups(_ view: PHIPGWMainButtonGroupView, didPressDisconnectAllButton button: UIButton) {}
}

class PHIPGWMainButtonGroupView: UIView {

    weak var delegate: PHIPGWMainButtonGroupViewDelegate?

    static let buttonHeight = PHGlobal.font.regular.pointSize * 3

    let connectButton: UIButton = {
        let button = UIButton()
        button.titleForNormal = "Connect"
        button.titleColorForNormal = .red
        button.titleLabel?.font = PHGlobal.font.regular
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .white
        return button
    }()

    let disconnectButton: UIButton = {
        let button = UIButton()
        button.titleForNormal = "Disconnect"
        button.titleColorForNormal = .blue
        button.titleLabel?.font = PHGlobal.font.regular
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .white
        return button
    }()

    let disconnectAllButton: UIButton = {
        let button = UIButton()
        button.titleForNormal = "Disconnect All"
        button.titleColorForNormal = .blue
        button.titleLabel?.font = PHGlobal.font.regular
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .white
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .none

        addSubviews([connectButton, disconnectButton, disconnectAllButton])

        let buttonHeight = PHIPGWMainButtonGroupView.buttonHeight

        connectButton.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(buttonHeight)
        }

        disconnectButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.left.equalTo(connectButton.snp.centerX)
            make.top.equalTo(connectButton.snp.bottom)
            make.height.equalTo(buttonHeight)
        }

        disconnectAllButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.right.equalTo(connectButton.snp.centerX)
            make.top.equalTo(connectButton.snp.bottom)
            make.height.equalTo(buttonHeight)
        }

        connectButton.addTarget(self, action: #selector(connectButtonTapped(_:)), for: .touchUpInside)
        disconnectButton.addTarget(self, action: #selector(disconnectButtonTapped(_:)), for: .touchUpInside)
        disconnectAllButton.addTarget(self, action: #selector(disconnectAllButtonTapped(_:)), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

//        connectButton.layer.borderColor = UIColor.red.cgColor
//        connectButton.layer.borderWidth = 2
//        connectButton.roundCorners(.allCorners, radius: 5)
//
//        disconnectButton.layer.borderColor = UIColor.blue.cgColor
//        disconnectButton.layer.borderWidth = 2
//        disconnectButton.roundCorners(.allCorners, radius: 5)
//
//        disconnectAllButton.layer.borderColor = UIColor.blue.cgColor
//        disconnectAllButton.layer.borderWidth = 2
//        disconnectAllButton.roundCorners(.allCorners, radius: 5)

        connectButton.addBorder(side: .top, thickness: 2, color: .blue)
        connectButton.addBorder(side: .bottom, thickness: 2, color: .blue)
        disconnectButton.addBorder(side: .left, thickness: 1, color: .blue)
        disconnectButton.addBorder(side: .bottom, thickness: 2, color: .blue)
        disconnectAllButton.addBorder(side: .right, thickness: 1, color: .blue)
        disconnectAllButton.addBorder(side: .bottom, thickness: 2, color: .blue)
    }

    @objc func connectButtonTapped(_ button: UIButton) {
        debugPrint("connect button tapped")
        delegate?.buttonGroups(self, didPressConnectButton: button)
    }

    @objc func disconnectButtonTapped(_ button: UIButton) {
        debugPrint("disconnect button tapped")
        delegate?.buttonGroups(self, didPressDisconnectButton: button)
    }

    @objc func disconnectAllButtonTapped(_ button: UIButton) {
        debugPrint("disconnectall button tapped")
        delegate?.buttonGroups(self, didPressDisconnectAllButton: button)
    }
}
