//
//  PHHoleTranslucentWritingBaseViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/17.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

protocol PHHoleTranslucentWritingViewControllerDelegate: AnyObject {

    func writingViewHeader(_ writingViewController: PHHoleTranslucentWritingBaseViewController, didPressCancelButton button: UIButton)
    func writingViewHeader(_ writingViewController: PHHoleTranslucentWritingBaseViewController, didPressConfirmButton button: UIButton)
    func writingViewWillAppear(_ writingViewController: PHHoleTranslucentWritingBaseViewController)
    func writingViewDidDisappear(_ writingViewController: PHHoleTranslucentWritingBaseViewController)
}

extension PHHoleTranslucentWritingViewControllerDelegate {

    func writingViewHeader(_ writingViewController: PHHoleTranslucentWritingBaseViewController, didPressCancelButton button: UIButton) {}
    func writingViewHeader(_ writingViewController: PHHoleTranslucentWritingBaseViewController, didPressConfirmButton button: UIButton) {}
    func writingViewWillAppear(_ writingViewController: PHHoleTranslucentWritingBaseViewController) {}
    func writingViewDidDisappear(_ writingViewController: PHHoleTranslucentWritingBaseViewController) {}
}

class PHHoleTranslucentWritingBaseViewController: PHBaseViewController {

    weak var delegate: PHHoleTranslucentWritingViewControllerDelegate?

    let headerView: UIView = {
        let view = UIView()
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Write something here"
        label.font = PHGlobal.font.regularBold
        label.textColor = .white
        return label
    }()

    let cancelButton: UIButton = {
        let button = UIButton()
        button.titleForNormal = "Cancel"
        button.titleColorForNormal = .white
        button.titleLabel?.font = PHGlobal.font.regularBold
        return button
    }()

    let confirmButton: UIButton = {
        let button = UIButton()
        button.titleForNormal = "Confirm"
        button.titleColorForNormal = .white
        button.titleColorForDisabled = .lightGray
        button.titleLabel?.font = PHGlobal.font.regularBold
        return button
    }()

    let inputTextView: KMPlaceholderTextView = {
        let view = KMPlaceholderTextView()
        view.backgroundColor = .clear
        view.placeholderLabel.backgroundColor = .clear
        view.textColor = .white
        view.placeholderColor = .lightText
        view.placeholder = "Enter something here ..."
        view.font = PHGlobal.font.regularBold
        view.placeholderFont = PHGlobal.font.regular
        view.keyboardType = .default
        view.returnKeyType = .default
        return view
    }()

    var content: String? {
        return inputTextView.text.trimmed.empty2Nil()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // BackgroundColor must be set before viewDidLoad() !!
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        modalPresentationStyle = .overCurrentContext
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: R.image.keyboard_down(), style: .plain, target: self, action: #selector(hideKeyboard)),
        ]
        toolBar.sizeToFit()

        inputTextView.inputAccessoryView = toolBar
        inputTextView.delegate = self

        cancelButton.addTarget(self, action: #selector(headerCancelButtonTapped(_:)), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(headerConfirmButtonTapped(_:)), for: .touchUpInside)
        confirmButton.isEnabled = false

        view.addSubviews([headerView, inputTextView])
        headerView.addSubviews([titleLabel, cancelButton, confirmButton])

        inputTextView.textContainerInset = UIEdgeInsets(px: PHGlobal.sideSpacing, py: PHGlobal.sideSpacing)

        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(PHGlobal.statusBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(PHGlobal.navBarHeight)
        }

        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        cancelButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(PHGlobal.sideSpacing)
        }

        confirmButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(PHGlobal.sideSpacing)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.writingViewWillAppear(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.writingViewDidDisappear(self)
    }

    // This is design for derived singleton class
    func reset() {}
}

extension PHHoleTranslucentWritingBaseViewController {

    @objc func headerCancelButtonTapped(_ button: UIButton) {
        delegate?.writingViewHeader(self, didPressCancelButton: button)
    }

    @objc func headerConfirmButtonTapped(_ button: UIButton) {
        inputTextView.endEditing(true)
        delegate?.writingViewHeader(self, didPressConfirmButton: button)
    }

    @objc func hideKeyboard() {
        if inputTextView.isFirstResponder {
            inputTextView.resignFirstResponder()
        }
    }

    @objc func showKeyboard() {
        if !inputTextView.isFirstResponder {
            inputTextView.becomeFirstResponder()
        }
    }

    func checkIsConfirmButtonEnabled() {
        confirmButton.isEnabled = !inputTextView.text.trimmed.isEmpty
    }
}

extension PHHoleTranslucentWritingBaseViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        debugPrint("did change")
        checkIsConfirmButtonEnabled()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        debugPrint("did begin editing")
        checkIsConfirmButtonEnabled()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        debugPrint("did end editing")
    }
}
