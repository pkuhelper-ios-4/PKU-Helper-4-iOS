//
//  PHHoleWritePostViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import PPBadgeViewSwift
import Lightbox
import KMPlaceholderTextView
import WXImageCompress
import PopupDialog

class PHHoleWritePostViewController: PHBaseViewController {

    let inputTextView: KMPlaceholderTextView = {
        let view = KMPlaceholderTextView()
        view.backgroundColor = .clear
        view.placeholder = "Enter your post here ..."
        view.font = PHGlobal.font.regular
        view.placeholderFont = PHGlobal.font.regular
        view.textColor = .black
        view.keyboardType = .default
        view.returnKeyType = .default
        return view
    }()

    let imagePickerController: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.allowsEditing = false
        controller.mediaTypes = ["public.image"]
        return controller
    }()

    fileprivate var pictureBarButtonItem: UIBarButtonItem?

    var selectedImage: UIImage? {
        didSet {
            guard let pictureButton = pictureBarButtonItem else { return }
            if selectedImage != nil {
                pictureButton.pp.addDot(color: .red)
            } else {
                pictureButton.pp.hiddenBadge()
            }
            checkIsPostButtonEnabled()
        }
    }

    var currentContent: String? {
        return inputTextView.text.trimmed.empty2Nil()
    }

    fileprivate weak var memoSyncTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Anonymous post"
        view.backgroundColor = .white

        setNavigationBackButtonTarget(action: #selector(navBarBackButtonTapped))

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(navBarPostButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false

        let toolBar = UIToolbar()
        toolBar.barStyle = .default

        toolBar.items = [
            UIBarButtonItem(image: R.image.picture(), style: .plain, target: self, action: #selector(toolBarPictureButtonTapped)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: R.image.keyboard_down(), style: .plain, target: self, action: #selector(hideKeyboard)),
        ]
        pictureBarButtonItem = toolBar.items![0]
        toolBar.sizeToFit()

        inputTextView.inputAccessoryView = toolBar
        inputTextView.delegate = self

        view.addSubview(inputTextView)
        inputTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        inputTextView.textContainerInset = UIEdgeInsets(px: PHGlobal.sideSpacing, py: PHGlobal.sideSpacing * 0.8)

        imagePickerController.delegate = self

        // Preload memo here for data initialization and content display
        // The UIBarButtonItem of toolBar will not be initialized until the UITextField goes into edit mode for the first time.
        // At that time, memo will be load again.
        loadPostMemo()
    }

    fileprivate var isInitLoadPostMemo: Bool = false

    override var isViewLoaded: Bool {
        // delay load memo here to ensure the button of UIBarbuttonItem has initialized
        if !isInitLoadPostMemo {
            guard let item = pictureBarButtonItem, item.isButtonInitialized else { return super.isViewLoaded }
            isInitLoadPostMemo = true
            loadPostMemo()
            memoSyncTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(scheduledSyncPostMemo(_:)), userInfo: nil, repeats: true)
        }
        return super.isViewLoaded
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar(animated: animated)
    }

    // MARK: Disable pop gesture to prevent unexpected exit

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

extension PHHoleWritePostViewController {

    func loadPostMemo() {
        guard let memo = PHPostMemo.default else { return }
        inputTextView.text = memo.content
        selectedImage = memo.image
    }

    func dumpPostMemo() {
        let memo = PHPostMemo()
        memo.content = currentContent
        memo.image = selectedImage
        PHPostMemo.default = memo
    }

    func clearPostMemo() {
        PHPostMemo.default = nil
    }

    @objc func scheduledSyncPostMemo(_ timer: Timer) {
        debugPrint("sync post memo")
    }
}

extension PHHoleWritePostViewController {

    func popCurrentPage() {
        memoSyncTimer?.invalidate()
        navigationController?.popViewController(animated: true)
    }

    @objc func navBarBackButtonTapped() {
        inputTextView.endEditing(true)

        guard currentContent != nil || selectedImage != nil else {
            clearPostMemo()
            popCurrentPage()
            return
        }

        let popup = PopupDialog(title: "Save draft",
                                message: "Do you want to save draft before exit? Your previous draft is no longer retained.",
                                image: PHAlert.infoHeaderImage,
                                buttonAlignment: .horizontal,
                                transitionStyle: .fadeIn)

        let saveButton = DefaultButton(title: "SAVE") { [weak self] in
            self?.dumpPostMemo()
            self?.popCurrentPage()
        }

        let dontSaveButton = DestructiveButton(title: "DON'T SAVE") { [weak self] in
            self?.clearPostMemo()
            self?.popCurrentPage()
        }

        popup.addButtons([dontSaveButton, saveButton])
        present(popup, animated: true, completion: nil)
    }

    @objc func navBarPostButtonTapped() {
        inputTextView.endEditing(true)
        submitPost()
    }

    @objc func toolBarPictureButtonTapped() {
        guard presentedViewController == nil else {
            // TODO: How to disable the up slide gestrue that will show the keyboard
            hideKeyboard()
            return
        }
        if let image = selectedImage {

            LightboxConfig.DeleteButton.enabled = true
            LightboxConfig.hideStatusBar = false
            LightboxConfig.InfoLabel.enabled = false
            LightboxConfig.PageIndicator.enabled = false

            let images = [
                LightboxImage(image: image)
            ]
            let controller = LightboxController(images: images)
            controller.dismissalDelegate = self

            controller.headerView.deleteButton.addTarget(self, action: #selector(lightBoxDeleteButtonTapped), for: .touchUpInside)
            controller.headerView.closeButton.addTarget(self, action: #selector(lightBoxCloseButtonTapped), for: .touchUpInside)

            controller.dynamicBackground = false

            present(controller, animated: true, completion: nil)
        } else {
            present(imagePickerController, animated: true, completion: nil)
        }
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

    func checkIsPostButtonEnabled() {
        guard let postButton = navigationItem.rightBarButtonItem else { return }
        postButton.isEnabled = !inputTextView.text.trimmed.isEmpty || selectedImage != nil
    }

    @objc func lightBoxDeleteButtonTapped() {
        selectedImage = nil
        showKeyboard()
    }

    @objc func lightBoxCloseButtonTapped() {
        showKeyboard()
    }
}

extension PHHoleWritePostViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        debugPrint("textView change")
        checkIsPostButtonEnabled()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        debugPrint("begin edit")
        checkIsPostButtonEnabled()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        debugPrint("end edit")
    }
}

extension PHHoleWritePostViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origin = info[.originalImage] as? UIImage? {
            selectedImage = origin
        }
        picker.dismiss(animated: true, completion: nil)
        showKeyboard()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        showKeyboard()
    }

}

extension PHHoleWritePostViewController: UINavigationControllerDelegate {

}

extension PHHoleWritePostViewController: LightboxControllerDismissalDelegate {

    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        showKeyboard()
    }
}


extension PHHoleWritePostViewController {

    func submitPost() {
        guard let user = PHUser.default else {
            PHAlert(on: self)?.infoLoginRequired()
            return
        }

        let errorHandler: (PHBackendError.Errcode, PHBackendError) -> Void = {
            [weak self] errcode, error in
            switch errcode {
            case .pkuHoleUserBeBanned:
                PHAlert(on: self)?.infoUserBeBanned()
            case .pkuHoleContainsSensitiveWords:
                PHAlert(on: self)?.infoContainSensitiveWords()


            case .operationNotAllowed:
                PHAlert(on: self)?.warningOperationNotAllowed()
            default:
                PHAlert(on: self)?.backendError(error)
            }
        }

        let detailHandler = { [weak self] (detail: PHV2NullDetail) in
            PHHoleMainViewController.shared.fetchLatestPostList()
            self?.clearPostMemo()
            self?.popCurrentPage()
        }

        if let image = selectedImage {
            guard let imageData = image.wxCompress().jpegData(compressionQuality: 0.5) else { return }
            let text = currentContent ?? ""
            PHBackendAPI.upload(
                PHBackendAPI.PKUHole.submitPost(text: text, type: .image, utoken: user.utoken),
                multipartFormData: { (multipartFormData) in
                    multipartFormData.append(imageData, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
                },
                on: self,
                errorHandler: errorHandler,
                detailHandler: detailHandler
            )
        } else {
            guard let text = currentContent else { return }
            PHBackendAPI.request(
                PHBackendAPI.PKUHole.submitPost(text: text, type: .text, utoken: user.utoken),
                on: self,
                errorHandler: errorHandler,
                detailHandler: detailHandler
            )
        }
    }
}
