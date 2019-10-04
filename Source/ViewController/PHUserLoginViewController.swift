//
//  PHUserLoginViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import PopupDialog

class PHUserLoginViewController: PHBaseViewController {

    let loginFormView = PHUserLoginFormView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Login"

        loginFormView.delegate = self

        view.addSubview(loginFormView)
        loginFormView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(PHGlobal.topBarsHeight)
            make.left.right.bottom.equalToSuperview()
        }
    }

    var verifiedUid: String? {
        didSet {
            loginFormView.isLockLoginButton = (verifiedUid == nil)
        }
    }
}

extension PHUserLoginViewController: PHUserLoginFormViewDelegate {

    func loginForm(_ loginFormView: PHUserLoginFormView, didPressSendValidCodeButton button: UIButton) {
        debugPrint("send validcode button tapped")
        guard let uid = loginFormView.uid else { return }

        let popup = PopupDialog(title: "Select the target",
                                message: "Where do you want the validation code to be sent?",
                                image: PHAlert.infoHeaderImage,
                                buttonAlignment: .horizontal,
                                transitionStyle: .fadeIn)

        let emailButton = DefaultButton(title: "EMAIL") { [weak self] in
            self?.confirmEmailAddress(uid: uid)
        }

        let phoneButton = DefaultButton(title: "PHONE") { [weak self] in
            self?.checkPhoneNumber(uid: uid)
        }

        popup.addButtons([emailButton, phoneButton])
        present(popup, animated: true, completion: nil)
    }

    func loginForm(_ loginFormView: PHUserLoginFormView, didPressLoginButton loginButton: UIButton) {
        guard let uid = self.verifiedUid else { return }
        guard let validCode = loginFormView.validCode else { return }
        loginFormView.isLockLoginButton = true // require lock
        PHBackendAPI.request(
            PHBackendAPI.Login.isopLogin(uid: uid, validCode: validCode),
            on: self,
            errorHandler: { [weak self] error in
                loginFormView.isLockLoginButton = false
                PHAlert(on: self)?.backendError(error)
            },
            detailHandler: { [weak self] (detail: PHV2Login) in
                guard let strongSelf = self else { return }
                loginFormView.isLockLoginButton = false
                let user = detail
                PHUser.default = user
                NotificationCenter.default.post(name: .PHUserDidLogin, object: nil)
                strongSelf.navigationController?.popViewController(animated: true)
            }
        )
    }
}

extension PHUserLoginViewController {

    func checkPhoneNumber(uid: String) {
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
                                    message: "If \(mobile) is not your currently used mobile phone number, you can login to https://portal.pku.edu.cn/ to modify your phone number through 'My Portal > Setting > Bound Phone Number'.")
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

        let okButton = DefaultButton(title: "OK") { [weak self] in
            self?.verifyCaptchaAndSendingValidCode(uid: uid, receiver: .email)
        }

        let cancelButton = CancelButton(title: "CANCEL", action: nil)

        popup.addButtons([cancelButton, okButton])
        present(popup, animated: true, completion: nil)
    }

    func verifyCaptchaAndSendingValidCode(uid: String, receiver: PHBackendAPI.Login.ValidcodeReceiver) {
        loginFormView.isLockSendValidCodeButton = true
        PHBackendAPI.request(
            PHBackendAPI.Login.getCaptchaForSendingValidcode(uid: uid),
            on: self,
            errorHandler: { [weak self] error in
                self?.loginFormView.isLockSendValidCodeButton = false
                PHAlert(on: self)?.backendError(error)
            },
            detailHandler: { [weak self] (detail: PHV2LoginGetCaptcha) in
                self?.loginFormView.isLockSendValidCodeButton = false

                let popupViewController = PHUserLoginCaptchaPopupViewController()
                popupViewController.uid = uid
                popupViewController.expires = detail.expires
                popupViewController.captcha = detail.captcha
                popupViewController.delegate = self

                let popup = PopupDialog(viewController: popupViewController,
                                        buttonAlignment: .horizontal,
                                        transitionStyle: .fadeIn,
                                        tapGestureDismissal: false,
                                        panGestureDismissal: false)

                let cancelButton = CancelButton(title: "CANCEL", action: nil)

                let okButton = DefaultButton(title: "CONFIRM", dismissOnTap: false) { [weak self] in
                    guard let captcha = popupViewController.currentCaptcha else { return }

                    PHBackendAPI.request(
                        PHBackendAPI.Login.sendValidcode(uid: uid, captcha: captcha, receiver: receiver),
                        on: self,
                        errorHandler: { [weak self] errcode, error in
                            switch errcode {
                            case .loginCaptchaExpired:
                                popupViewController.showCaptchaExpired()
                                self?.changeCaptcha(popupViewController)
                            case .loginBadCaptcha:
                                popupViewController.showCaptchaWrong()
                            default:
                                PHAlert(on: self)?.backendError(error)
                            }
                        },
                        detailHandler: { [weak self] (detail: PHV2LoginSendValidcode) in
                            PHAlert(on: self)?.success(message: detail.message)
                            self?.verifiedUid = uid // This uid will actually be used in the later login
                        }
                    )
                }

                // Add buttons to dialog
                popup.addButtons([cancelButton, okButton])
                self?.present(popup, animated: true, completion: nil)
            }
        )
    }

    func changeCaptcha(_ popupViewController: PHUserLoginCaptchaPopupViewController?) {
        guard let uid: String = popupViewController?.uid else { return }
        PHBackendAPI.request(
            PHBackendAPI.Login.getCaptchaForSendingValidcode(uid: uid),
            on: self)
        {
            (detail: PHV2LoginGetCaptcha) in
            popupViewController?.captcha = detail.captcha
            popupViewController?.expires = detail.expires
            popupViewController?.captchaTextField.clear()
        }
    }
}

extension PHUserLoginViewController: PHUserLoginCaptchaPopupViewControllerDelegate {

    func captchaPopup(_ popupViewController: PHUserLoginCaptchaPopupViewController, didPressChangeButton button: UIButton) {
        changeCaptcha(popupViewController)
    }
}
