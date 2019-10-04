//
//  PHUserLoginCaptchaPopupViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/12.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit

protocol PHUserLoginCaptchaPopupViewControllerDelegate: AnyObject {

    func captchaPopup(_ popupViewController: PHUserLoginCaptchaPopupViewController, didPressChangeButton replaceButton: UIButton)
    func captchaPopup(_ popupViewController: PHUserLoginCaptchaPopupViewController, captchaTextFieldDidChange captchaTextField: UITextField)
}

extension PHUserLoginCaptchaPopupViewControllerDelegate {

    func captchaPopup(_ popupViewController: PHUserLoginCaptchaPopupViewController, didPressChangeButton replaceButton: UIButton) {}
    func captchaPopup(_ popupViewController: PHUserLoginCaptchaPopupViewController, captchaTextFieldDidChange captchaTextField: UITextField) {}
}

class PHUserLoginCaptchaPopupViewController: PHBaseViewController {

    weak var delegate: PHUserLoginCaptchaPopupViewControllerDelegate?
    let maxCaptchaLength: Int = 6

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter captcha before sending validcode"
        label.font = PHGlobal.font.regularBold
        return label
    }()

    let captchaImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .red
        return view
    }()

    let captchaChangeButton: UIButton = {
        let button = UIButton()
        button.setTitle("change", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = PHGlobal.font.small
        return button
    }()

    let captchaTextField: UITextField = {
        let field = UITextField()
        field.keyboardType = .asciiCapable
        field.clearButtonMode = .whileEditing
        field.font = PHGlobal.font.regular
        field.textColor = .black
        field.backgroundColor = .lightGray
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
        captchaTextField.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(PHGlobal.font.regular.pointSize * CGFloat(maxCaptchaLength))
        }

        captchaTextField.addTarget(self, action: #selector(captchaTextFieldDidChange(_:)), for: .editingChanged)
        captchaChangeButton.addTarget(self, action: #selector(replaceCaptchaButtonTapped(_:)), for: .touchUpInside)
    }
}

extension PHUserLoginCaptchaPopupViewController {

    @objc func captchaTextFieldDidChange(_ sender: UITextField) {
        captchaTextField.placeholder = nil
        delegate?.captchaPopup(self, captchaTextFieldDidChange: sender)
    }

    @objc func replaceCaptchaButtonTapped(_ sender: UIButton) {
        delegate?.captchaPopup(self, didPressChangeButton: sender)
    }

    func showCaptchaExpired() {
        if captchaTextField.isEditing {
            captchaTextField.endEditing(true)
        }
        captchaTextField.clear()
        captchaTextField.placeholder = "expired"
        captchaTextField.setPlaceHolderTextColor(.red)
    }

    func showCaptchaWrong() {
        if captchaTextField.isEditing {
            captchaTextField.endEditing(true)
        }
        captchaTextField.clear()
        captchaTextField.placeholder = "wrong"
        captchaTextField.setPlaceHolderTextColor(.red)
    }
}

extension PHUserLoginCaptchaPopupViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (textField.text?.trimmed.count ?? 0) < maxCaptchaLength
    }
}
**/
