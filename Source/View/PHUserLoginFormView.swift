//
//  PHUserLoginFormView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift

protocol PHUserLoginFormViewDelegate: AnyObject {

    func loginForm(_ loginFormView: PHUserLoginFormView, didPressSendValidCodeButton button: UIButton)
    func loginForm(_ loginFormView: PHUserLoginFormView, didPressLoginButton button: UIButton)
}

extension PHUserLoginFormViewDelegate {

    func loginForm(_ loginFormView: PHUserLoginFormView, didPressSendValidCodeButton button: UIButton) {}
    func loginForm(_ loginFormView: PHUserLoginFormView, didPressLoginButton loginButton: UIButton) {}
}

class PHUserLoginFormView: UIView {

    weak var delegate: PHUserLoginFormViewDelegate?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.largestBold
        label.textColor = .black
        label.text = "Welcome to PKU Helper"
        return label
    }()

    let uidTextField: UITextField = {
        let field = SkyFloatingLabelTextFieldWithIcon(frame: .zero, iconType: .font)
        field.title = "Student ID / Staff ID"
        field.placeholder = "Enter \(field.title ?? "")"
        let font = PHGlobal.font.regular
        field.font = font
        field.iconFont = UIFont.fontAwesome(ofSize: font.pointSize * 1.2, style: .solid)
        field.iconText = String.fontAwesomeIcon(name: .user)
        field.iconMarginBottom = font.pointSize * 0.5
        field.iconMarginLeft = font.pointSize * 0.8
        field.selectedIconColor = .blue
        field.errorColor = .red
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done
        return field
    }()

    let validCodeTextField: UITextField = {
        let field = SkyFloatingLabelTextFieldWithIcon(frame: .zero, iconType: .font)
        field.title = "Validation Code"
        field.placeholder = "Enter \(field.title ?? "")"
        let font = PHGlobal.font.regular
        field.font = font
        field.iconFont = UIFont.fontAwesome(ofSize: font.pointSize * 1.2, style: .solid)
        field.iconText = String.fontAwesomeIcon(name: .checkCircle)
        field.iconMarginBottom = font.pointSize * 0.5
        field.iconMarginLeft = font.pointSize * 0.8
        field.selectedIconColor = .blue
        field.errorColor = .red
        field.clearButtonMode = .whileEditing
        field.keyboardType = .numberPad
        return field
    }()

    let sendValidCodeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send Validcode", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.backgroundColor = .blue
        return button
    }()

    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.backgroundColor = .red
        return button
    }()

    let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .fill
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(validCodeTextFieldToolbarDoneButtonTapped(_:))),
        ]
        toolBar.sizeToFit()
        validCodeTextField.inputAccessoryView = toolBar

        uidTextField.delegate = self
        validCodeTextField.delegate = self

        buttonStackView.addArrangedSubviews([sendValidCodeButton, loginButton])
        self.addSubviews([titleLabel, uidTextField, validCodeTextField, buttonStackView])

        let sideSpacing = PHGlobal.screenWidth * 0.08
        let fieldHeight = PHGlobal.font.regular.pointSize * 3.5
        let buttonHeight = PHGlobal.font.regular.pointSize * 2.5

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.equalToSuperview().offset(fieldHeight * 0.8)
        }

        uidTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.height.equalTo(fieldHeight)
            make.top.equalTo(titleLabel.snp.bottom).offset(fieldHeight * 0.6)
        }

        validCodeTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.height.equalTo(fieldHeight)
            make.top.equalTo(uidTextField.snp.bottom).offset(fieldHeight * 0.4)
        }

        buttonStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.height.equalTo(buttonHeight)
            make.top.equalTo(validCodeTextField.snp.bottom).offset(fieldHeight * 0.8)
        }
        buttonStackView.spacing = sideSpacing

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        uidTextField.addTarget(self, action: #selector(uidTextFieldDidChange(_:)), for: .editingChanged)
        validCodeTextField.addTarget(self, action: #selector(validCodeTextFieldDidChange(_:)), for: .editingChanged)
        sendValidCodeButton.addTarget(self, action: #selector(sendValidCodeButtonTapped(_:)), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)

        checkButtonsIsEnabled()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var uid: String? {
        return uidTextField.text?.trimmed.empty2Nil()
    }

    var validCode: String? {
        return validCodeTextField.text?.trimmed.empty2Nil()
    }

    var isLockSendValidCodeButton: Bool = false {
        didSet {
            guard oldValue != isLockSendValidCodeButton else { return }
            checkButtonsIsEnabled()
        }
    }

    var isLockLoginButton: Bool = true {
        didSet {
            guard oldValue != isLockLoginButton else { return }
            checkButtonsIsEnabled()
        }
    }

    var isValidUid: Bool = false {
        didSet {
            guard oldValue != isValidUid else { return }
            checkButtonsIsEnabled()
        }
    }

    var isValidValidCode: Bool = false {
        didSet {
            guard oldValue != isValidValidCode else { return }
            checkButtonsIsEnabled()
        }
    }

    var isSendValidCodeButtonEnabled: Bool {
        return isValidUid && !isLockSendValidCodeButton
    }

    var isLoginButtonEnabled: Bool {
        return isValidUid && isValidValidCode && !isLockLoginButton
    }
}

extension PHUserLoginFormView {

    func checkButtonsIsEnabled() {
        debugPrint("check buttons isEnabled")
        sendValidCodeButton.isEnabled = isSendValidCodeButtonEnabled
        loginButton.isEnabled = isLoginButtonEnabled
    }

    @objc func hideKeyboard() {
        [uidTextField, validCodeTextField].forEach { $0.resignFirstResponder() }
    }

    @objc func validCodeTextFieldToolbarDoneButtonTapped(_ item: UIBarButtonItem) {
        validCodeTextField.resignFirstResponder()
    }

    @objc func uidTextFieldDidChange(_ textField: UITextField) {
        guard let field = textField as? SkyFloatingLabelTextField else { return }
        guard let uid = self.uid else {
            field.errorMessage = nil
            isValidUid = false
            return
        }
        if uid.count > 13 {
            field.errorMessage = "Invalid \(field.title ?? "")"
            isValidUid = false
        } else {
            field.errorMessage = nil
            isValidUid = true
        }
    }

    @objc func validCodeTextFieldDidChange(_ textField: UITextField) {
        guard let field = textField as? SkyFloatingLabelTextField else { return }
        guard let validCode = self.validCode else {
            field.errorMessage = nil
            isValidValidCode = false
            return
        }
        if validCode.count < 4 || validCode.count > 8 {
            field.errorMessage = "Invalid \(field.title ?? "")"
            isValidValidCode = false
        } else {
            field.errorMessage = nil
            isValidValidCode = true
        }
    }

    @objc func sendValidCodeButtonTapped(_ button: UIButton) {
        [uidTextField, validCodeTextField].forEach { $0.resignFirstResponder() }
        delegate?.loginForm(self, didPressSendValidCodeButton: button)
    }

    @objc func loginButtonTapped(_ button: UIButton) {
        [uidTextField, validCodeTextField].forEach { $0.resignFirstResponder() }
        delegate?.loginForm(self, didPressLoginButton: button)
    }
}

extension PHUserLoginFormView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
