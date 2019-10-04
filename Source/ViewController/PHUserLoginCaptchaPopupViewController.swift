//
//  PHUserLoginCaptchaPopupViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

protocol PHUserLoginCaptchaPopupViewControllerDelegate: AnyObject {

    func captchaPopup(_ popupViewController: PHUserLoginCaptchaPopupViewController, didPressChangeButton button: UIButton)
    func captchaPopup(_ popupViewController: PHUserLoginCaptchaPopupViewController, captchaTextFieldDidChange textField: UITextField)
}

extension PHUserLoginCaptchaPopupViewControllerDelegate {

    func captchaPopup(_ popupViewController: PHUserLoginCaptchaPopupViewController, didPressChangeButton button: UIButton) {}
    func captchaPopup(_ popupViewController: PHUserLoginCaptchaPopupViewController, captchaTextFieldDidChange textField: UITextField) {}
}

class PHUserLoginCaptchaPopupViewController: PHBaseViewController {

    weak var delegate: PHUserLoginCaptchaPopupViewControllerDelegate?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter captcha before sending validcode"
        label.font = PHGlobal.font.regularBold
        return label
    }()

    let captchaImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    let captchaChangeButton: UIButton = {
        let button = UIButton()
        button.setTitle("change", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = PHGlobal.font.small
        return button
    }()

    let captchaTextField: UITextField = {
        let field = UITextField()
        field.font = PHGlobal.font.regular
        field.textColor = .black
        field.backgroundColor = UIColor.groupTableViewBackground
        field.borderStyle = .roundedRect
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
        field.keyboardType = .asciiCapable
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done
        return field
    }()

    let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()

    var uid: String!
    var expires: Int!
    var captcha: PHV2LoginCaptcha! {
        didSet {
            captchaImageView.image = captcha.captchaImage
        }
    }

    var currentCaptcha: String? {
        return captchaTextField.text?.trimmed.empty2Nil()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        captchaTextField.delegate = self

        let sideSpacing = PHGlobal.font.regular.pointSize * 1.5
        let lineSpacing = PHGlobal.font.regular.pointSize * 2

        view.addSubviews([titleLabel, contentStackView])

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(lineSpacing)
        }

        contentStackView.spacing = sideSpacing / 2
        contentStackView.addArrangedSubviews([captchaImageView, captchaTextField, captchaChangeButton])

        contentStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.equalTo(titleLabel.snp.bottom).offset(lineSpacing)
            make.bottom.equalToSuperview().inset(lineSpacing)
        }

        captchaImageView.snp.makeConstraints { make in
            make.width.equalTo(captcha.width)
            make.height.equalTo(captcha.height)
        }

        captchaChangeButton.setContentHuggingPriority(.required, for: .horizontal)
        captchaChangeButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        captchaTextField.addTarget(self, action: #selector(captchaTextFieldDidChange(_:)), for: .editingChanged)
        captchaChangeButton.addTarget(self, action: #selector(replaceCaptchaButtonTapped(_:)), for: .touchUpInside)
    }
}

extension PHUserLoginCaptchaPopupViewController {

    @objc func captchaTextFieldDidChange(_ textField: UITextField) {
        captchaTextField.placeholder = nil
        delegate?.captchaPopup(self, captchaTextFieldDidChange: textField)
    }

    @objc func replaceCaptchaButtonTapped(_ button: UIButton) {
        delegate?.captchaPopup(self, didPressChangeButton: button)
    }

    func showCaptchaExpired() {
        captchaTextField.endEditing(true)
        captchaTextField.clear()
        captchaTextField.placeholder = "expired"
        captchaTextField.setPlaceHolderTextColor(.red)
    }

    func showCaptchaWrong() {
        captchaTextField.endEditing(true)
        captchaTextField.clear()
        captchaTextField.placeholder = "wrong"
        captchaTextField.setPlaceHolderTextColor(.red)
    }
}

extension PHUserLoginCaptchaPopupViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(false)
        return true
    }
}
