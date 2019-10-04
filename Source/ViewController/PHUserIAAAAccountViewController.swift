//
//  PHUserIAAAAccountViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SafariServices

protocol PHUserIAAAAccountViewControllerDelegate: AnyObject {

    func iaaaAcount(_ viewController: PHUserIAAAAccountViewController, didPressSaveButton button: UIButton)
}

extension PHUserIAAAAccountViewControllerDelegate {

    func iaaaAcount(_ viewController: PHUserIAAAAccountViewController, didPressSaveButton button: UIButton) {}
}

class PHUserIAAAAccountViewController: PHBaseViewController {

    weak var delegate: PHUserIAAAAccountViewControllerDelegate?

    let uidTextField: UITextField = {
        let field = SkyFloatingLabelTextFieldWithIcon(frame: .zero, iconType: .font)
        field.title = "Student ID / Staff ID"
        let font = PHGlobal.font.regular
        field.font = font
        field.iconFont = UIFont.fontAwesome(ofSize: font.pointSize * 1.2, style: .solid)
        field.iconText = String.fontAwesomeIcon(name: .user)
        field.iconMarginBottom = font.pointSize * 0.5
        field.iconMarginLeft = font.pointSize * 0.8
        field.disabledColor = .black
        field.isEnabled = false
        field.returnKeyType = .done
        return field
    }()

    let passwordTextField: UITextField = {
        let field = SkyFloatingLabelTextFieldWithIcon(frame: .zero, iconType: .font)
        field.title = "IAAA Password"
        field.placeholder = "Enter Your IAAA Password"
        let font = PHGlobal.font.regular
        field.font = font
        field.iconFont = UIFont.fontAwesome(ofSize: font.pointSize * 1.2, style: .solid)
        field.iconText = String.fontAwesomeIcon(name: .key)
        field.iconMarginBottom = font.pointSize * 0.5
        field.iconMarginLeft = font.pointSize * 0.8
        field.selectedIconColor = .blue
        field.clearButtonMode = .whileEditing
        field.isSecureTextEntry = true
        field.returnKeyType = .done
        return field
    }()

    let privacyPolicyLinkButton: UIButton = {
        let button = UIButton()
        button.titleForNormal = "Privacy Policy of PKU Helper"
        button.titleColorForNormal = .blue
        button.titleLabel?.font = PHGlobal.font.regular
        return button
    }()

    let saveButton: UIButton = {
        let button = UIButton()
        button.titleForNormal = "Save"
        button.titleColorForNormal = .white
        button.backgroundColor = .blue
        button.titleLabel?.font = PHGlobal.font.regular
        return button
    }()

    var iaaaPassword: String? {
        return passwordTextField.text?.trimmed.empty2Nil()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "IAAA Account"

        view.backgroundColor = .white

        uidTextField.delegate = self
        passwordTextField.delegate = self

        guard let user = PHUser.default else {
            navigationController?.popViewController(animated: true)
            return
        }
        uidTextField.text = user.uid

        let sideSpacing = PHGlobal.screenWidth * 0.08
        let fieldHeight = PHGlobal.font.regular.pointSize * 3.5
        let buttonHeight = PHGlobal.font.regular.pointSize * 2.5

        view.addSubviews([uidTextField, passwordTextField, privacyPolicyLinkButton, saveButton])

        uidTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.height.equalTo(fieldHeight)
            make.top.equalToSuperview().offset(PHGlobal.topBarsHeight + fieldHeight * 0.8)
        }

        passwordTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.height.equalTo(fieldHeight)
            make.top.equalTo(uidTextField.snp.bottom).offset(fieldHeight * 0.4)
        }

        privacyPolicyLinkButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(sideSpacing)
            make.height.equalTo(buttonHeight)
            make.top.equalTo(passwordTextField.snp.bottom).offset(fieldHeight * 0.8)
        }

        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.height.equalTo(buttonHeight)
            make.top.equalTo(privacyPolicyLinkButton.snp.bottom).offset(fieldHeight * 0.4)
        }

        privacyPolicyLinkButton.addTarget(self, action: #selector(privacyPolicyLinkButtonTapped(_:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
    }

    @objc func saveButtonTapped(_ button: UIButton) {
        delegate?.iaaaAcount(self, didPressSaveButton: button)
    }

    @objc func privacyPolicyLinkButtonTapped(_ button: UIButton) {
        let safari = SFSafariViewController(url: PHURL.privacyPolicyURL)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
    }
}

extension PHUserIAAAAccountViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PHUserIAAAAccountViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
