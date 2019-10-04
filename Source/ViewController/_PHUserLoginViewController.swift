//
//  PHUserLoginViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/12.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit
import PopupDialog

class PHUserLoginViewController: PHBaseViewController {

    let logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.logo.logo_black()
        return view
    }()

    let uidTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "User ID"
        field.clearButtonMode = .whileEditing
        field.keyboardType = .asciiCapable
        field.font = PHGlobal.font.regular
        field.textColor = .black
        field.backgroundColor = .lightGray
        field.addPaddingLeftIcon(R.image.user_male()!, padding: PHGlobal.font.regular.pointSize * 1.5)
        return field
    }()

    let validCodeTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Verification Code"
        field.clearButtonMode = .whileEditing
        field.keyboardType = .numberPad
        field.font = PHGlobal.font.regular
        field.textColor = .black
        field.backgroundColor = .lightGray
        field.addPaddingLeftIcon(R.image.security_checked()!, padding: PHGlobal.font.regular.pointSize * 1.5)
        return field
    }()

    let fetchValidCodeFromPhoneButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.phone(), for: .normal)
        return button
    }()

    let fetchValidCodeFromEmailButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.email(), for: .normal)
        return button
    }()

    let validCodeStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()

    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.backgroundColor = .red
        return button
    }()

    private var uid: String? // cache uid if needed

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Login"
        view.backgroundColor = .white

        let fieldWidth = PHGlobal.screenWidth * 0.8
        let fieldHeight = PHGlobal.font.regular.pointSize * 3

        view.addSubviews([logoImageView, uidTextField, validCodeStackView, loginButton])

        validCodeStackView.addArrangedSubviews([validCodeTextField, fetchValidCodeFromEmailButton, fetchValidCodeFromPhoneButton])
        validCodeStackView.spacing = PHGlobal.font.regular.pointSize

        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(fieldHeight * 2)
        }

        uidTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(fieldHeight * 0.5)
            make.width.equalTo(fieldWidth)
            make.height.equalTo(fieldHeight)
        }

        validCodeStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-fieldHeight).priority(.high)
            make.top.equalTo(uidTextField.snp.bottom).offset(fieldHeight * 0.5)
            make.width.equalTo(fieldWidth)
            make.height.equalTo(fieldHeight)
        }

        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(validCodeTextField.snp.bottom).offset(fieldHeight)
            make.width.equalTo(fieldWidth)
            make.height.equalTo(fieldHeight)
        }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:))))
        fetchValidCodeFromEmailButton.addTarget(self, action: #selector(fetchValidCodeFromEmailButtonTapped(_:)), for: .touchUpInside)
        fetchValidCodeFromPhoneButton.addTarget(self, action: #selector(fetchValidCodeFromPhoneButtonTapped(_:)), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        uidTextField.addTarget(self, action: #selector(uidTextFieldDidChange(_:)), for: .editingChanged)
        validCodeTextField.addTarget(self, action: #selector(validCodeTextFieldDidChange(_:)), for: .editingChanged)

        loginButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        showTabBar(animated: animated)
    }
}

extension PHUserLoginViewController {

    @objc func hideKeyboard(_ sender: UITapGestureRecognizer) {
        [uidTextField, validCodeTextField].forEach { field in
            if field.isFirstResponder {
                field.resignFirstResponder()
            }
        }
    }

    @objc func uidTextFieldDidChange(_ textField: UITextField) {
//        if let uid = textField.text, uid.count >= 0 {
//            fetchValidCodeButton.isEnabled = true
//        } else {
//            fetchValidCodeButton.isEnabled = false
//        }
    }

    @objc func validCodeTextFieldDidChange(_ textField: UITextField) {
        if let _ = textField.text?.trimmed.empty2Nil(), let _ = self.uid {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }

    @objc func fetchValidCodeFromPhoneButtonTapped(_ sender: UIButton) {
        guard let uid = uidTextField.text?.trimmed.empty2Nil() else { return }

        PHBackendAPI.request(
            PHBackendAPI.Login.getMobile(uid: uid),
            on: self,
            errorHandler: { [weak self] errcode, error in
                switch errcode {
                case .isopMobileNotFound:
                    PHAlert(on: self)?.warning(title: "Check your input",
                                               message: "The mobile phone number bound to account \(uid) was not found.")
                default:
                    PHAlert(on: self)?.backendError(error)
                }
            },
            detailHandler: { [weak self] (detail: PHV2LoginGetMobile) in
                self?.confirmPhoneNumber(uid: uid, mobile: detail.mobile)
            }
        )
    }

    @objc func fetchValidCodeFromEmailButtonTapped(_ sender: UIButton) {
        guard let uid = uidTextField.text?.trimmed.empty2Nil() else { return }
        /// skip comfirm email
        confirmEmailAddress(uid: uid)
    }

    func confirmPhoneNumber(uid: String, mobile: String) {
        let popup = PopupDialog(title: "Comfirm phone number",
                                message: "Ready to send verification code to your mobile \(mobile)",
                                image: PHAlert.infoHeaderImage,
                                buttonAlignment: .horizontal,
                                transitionStyle: .fadeIn)

        let okButton = DefaultButton(title: "OK") { [weak self] in
            self?.verifyCaptchaAndSendingValidCode(uid: uid, receiver: .mobile)
        }
        let cancelButton = CancelButton(title: "CANCEL") { [weak self] in
            PHAlert(on: self)?.info(title: "Tip",
                                    message: "If \(mobile) is not your currently used mobile phone number, you can login to https://portal.pku.edu.cn/ to modify your phone number through 'My Portal > Setting > Bound Phone Number'")
        }
        popup.addButtons([cancelButton, okButton])
        present(popup, animated: true, completion: nil)
    }

    func confirmEmailAddress(uid: String) {
        let popup = PopupDialog(title: "Comfirm email address",
                                message: "Ready to send verification code to your email \(uid)@pku.edu.cn",
                                image: PHAlert.infoHeaderImage,
                                buttonAlignment: .horizontal,
                                transitionStyle: .fadeIn)

        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        let okButton = DefaultButton(title: "OK") { [weak self] in
            self?.verifyCaptchaAndSendingValidCode(uid: uid, receiver: .email)
        }
        popup.addButtons([cancelButton, okButton])
        present(popup, animated: true, completion: nil)
    }

    func verifyCaptchaAndSendingValidCode(uid: String, receiver: PHBackendAPI.Login.ValidcodeReceiver) {
        PHBackendAPI.request(PHBackendAPI.Login.getCaptchaForSendingValidcode(uid: uid), on: self) {
            [weak self] (detail: PHV2LoginGetCaptcha) in

            let viewController = PHUserLoginCaptchaPopupViewController()
            viewController.uid = uid
            viewController.expires = detail.expires
            viewController.captcha = detail.captcha
            viewController.delegate = self

            let popup = PopupDialog(viewController: viewController,
                                    buttonAlignment: .horizontal,
                                    transitionStyle: .fadeIn,
                                    tapGestureDismissal: false,
                                    panGestureDismissal: false)

            let cancelButton = CancelButton(title: "CANCEL", action: nil)

            let okButton = DefaultButton(title: "CONFIRM", dismissOnTap: false) { [weak self] in
                guard let captcha = viewController.captchaTextField.text?.trimmed.empty2Nil() else { return }

                PHBackendAPI.request(
                    PHBackendAPI.Login.sendValidcode(uid: uid, captcha: captcha, receiver: receiver),
                    on: self,
                    errorHandler: { [weak self, weak viewController] errcode, error in
                        switch errcode {
                        case .loginCaptchaExpired:
                            viewController?.showCaptchaExpired()
                            self?.changeCaptcha(viewController)
                        case .loginBadCaptcha:
                            viewController?.showCaptchaWrong()
                        default:
                            PHAlert(on: self)?.backendError(error)
                        }
                    },
                    detailHandler: { [weak self] (detail: PHV2LoginSendValidcode) in
                        PHAlert(on: self)?.success(message: detail.message)
                        self?.uid = uid // cache for login
                    }
                )
            }

            // Add buttons to dialog
            popup.addButtons([cancelButton, okButton])
            self?.present(popup, animated: true, completion: nil)
        }
    }

    func changeCaptcha(_ popupViewController: PHUserLoginCaptchaPopupViewController?) {
        guard let uid: String = popupViewController?.uid else { return }
        PHBackendAPI.request(PHBackendAPI.Login.getCaptchaForSendingValidcode(uid: uid), on: self) {
            [weak popupViewController] (detail: PHV2LoginGetCaptcha) in
            popupViewController?.captcha = detail.captcha
            popupViewController?.expires = detail.expires
            popupViewController?.captchaTextField.clear()
        }
    }

    @objc func loginButtonTapped(_ sender: UIButton) {
        guard
            let uid = self.uid,
            let validCode = validCodeTextField.text?.trimmed.empty2Nil()
            else { return }
        PHBackendAPI.request(PHBackendAPI.Login.isopLogin(uid: uid, validCode: validCode), on: self) {
            [weak self] (detail: PHV2Login) in
            let user = detail
            PHUser.default = user
            debugPrint(PHUser.default as Any)
            NotificationCenter.default.post(name: .PHUserDidLogin, object: nil)
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

extension PHUserLoginViewController: PHUserLoginCaptchaPopupViewControllerDelegate {

    func captchaPopup(_ popupViewController: PHUserLoginCaptchaPopupViewController, didPressChangeButton replaceButton: UIButton) {
        changeCaptcha(popupViewController)
    }
}
**/
