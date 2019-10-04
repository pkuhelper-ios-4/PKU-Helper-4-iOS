//
//  PHColorPickerRGBColorEditorBarView.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/10/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit

protocol PHColorPickerRGBColorEditorBarViewDelegate: AnyObject {

    func colorEditorBar(_ view: PHColorPickerRGBColorEditorBarView, didPressDoneButton button: UIButton)
}

extension PHColorPickerRGBColorEditorBarViewDelegate {

    func colorEditorBar(_ view: PHColorPickerRGBColorEditorBarView, didPressDoneButton button: UIButton) {}
}

class PHColorPickerRGBColorEditorBarView: UIView {

    weak var delegate: PHColorPickerRGBColorEditorBarViewDelegate?

    let redComponentLabel: UILabel = createComponentLabel("R:")
    let greenComponentLabel: UILabel = createComponentLabel("G:")
    let blueComponentLabel: UILabel = createComponentLabel("B:")
    let redComponentTextField: UITextField = createComponentTextField()
    let greenComponentTextField: UITextField = createComponentTextField()
    let blueComponentTextField: UITextField = createComponentTextField()

    let doneButton: UIButton = {
        let button = UIButton()
        button.titleForNormal = "Done"
        button.titleColorForNormal = .blue
        button.titleColorForDisabled = .lightGray
        return button
    }()

    let rgbStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()

    fileprivate lazy var rgbTextFields = [redComponentTextField, greenComponentTextField, blueComponentTextField]
    fileprivate lazy var rgbLabels = [redComponentLabel, greenComponentLabel, blueComponentLabel]

    var rgbInputView: UIView? {
        didSet {
            rgbTextFields.forEach { $0.inputView = rgbInputView }
        }
    }

    fileprivate static func createComponentLabel(_ text: String) -> UILabel {
        let label = UILabel()
        let font = PHGlobal.font.small
        label.frame = CGRect(x: 0, y: 0, width: font.pointSize * 2, height: 0)
        label.font = font
        label.textColor = .gray
        label.text = text
        return label
    }

    fileprivate static func createComponentTextField() -> UITextField {
        let field = UITextField()
        let font = PHGlobal.font.small
        field.frame = CGRect(x: 0, y: 0, width: font.pointSize * 8, height: 0)
        field.font = font
        field.textColor = .black
        field.keyboardType = .numberPad
        return field
    }

    var color: UIColor? {
        guard
            let red = getRGBComponentFromTextField(redComponentTextField),
            let green = getRGBComponentFromTextField(greenComponentTextField),
            let blue = getRGBComponentFromTextField(blueComponentTextField)
            else { return nil }
        return UIColor(red: red, green: green, blue: blue)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        rgbTextFields.forEach { $0.delegate = self }

        rgbStackView.addArrangedSubviews([
            redComponentLabel, redComponentTextField,
            greenComponentLabel, greenComponentTextField,
            blueComponentLabel, blueComponentTextField,
        ])

        addSubviews([rgbStackView, doneButton])

        let percent = PHColorPickerColorCircleCollectionViewCell.colorCircleDiameterPercent
        let sideSpacing = PHMultiColorPicker.sideSpacing + (PHColorPickerView.itemSideLength * (1 - CGFloat(percent)) / 2)
        let fieldSpacing = PHGlobal.font.small.pointSize

        rgbStackView.spacing = fieldSpacing

        rgbStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(sideSpacing)
        }

        doneButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().inset(sideSpacing)
            make.left.greaterThanOrEqualTo(rgbStackView.snp.right).offset(fieldSpacing)
        }

        doneButton.setContentHuggingPriority(.required, for: .horizontal)

        rgbTextFields.forEach { $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .valueChanged) }
        doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)

//        doneButton.isEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PHColorPickerRGBColorEditorBarView {

    fileprivate func getRGBComponentFromTextField(_ textField: UITextField) -> Int? {
        guard let text = blueComponentTextField.text else { return nil }
        guard let component = Int(text) else { return nil }
        guard component >= 0 && component <= 255 else { return nil }
        return component
    }

    func toggleDoneButtonEnabled() {
        doneButton.isEnabled = (color != nil)
    }

    @objc func doneButtonTapped(_ button: UIButton) {
        delegate?.colorEditorBar(self, didPressDoneButton: button)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        toggleDoneButtonEnabled()
    }
}

extension PHColorPickerRGBColorEditorBarView: UITextFieldDelegate {

    //
    // https://stackoverflow.com/questions/26919854/how-can-i-declare-that-a-text-field-can-only-contain-an-integer
    //
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Find out what the text field will be after adding the current edit
        guard
            let _range = Range(range, in: string),
            let text = textField.text?.replacingCharacters(in: _range, with: string)
            else { return true }

        if let component = Int(text), component >= 0 && component <= 255 {
            // Text field converted to an Int
        } else {
            // Text field is not an Int
        }

        // Return true so the text field will be changed
        return true
    }
}
**/


//extension PHColorPickerView: PHColorPickerRGBColorEditorBarViewDelegate {
//
//    func colorEditorBar(_ view: PHColorPickerRGBColorEditorBarView, didPressDoneButton button: UIButton) {
//        debugPrint("color editor did press done button")
//        hideEditorBar()
//    }
//}

//extension PHColorPickerView {
//
//    func showEditorBar() {
//        let editorBar = self.editorBar
//        let collectionView = self.collectionView
//
//        guard editorBar.isHidden else { return }
//        editorBar.isHidden = false
//
//        var newCollectionViewFrame = collectionView.frame
//        newCollectionViewFrame.origin.y += editorBar.frame.height
//
//        UIView.animate(withDuration: 0.3, animations: {
//            collectionView.frame = newCollectionViewFrame
//        })
//    }
//
//    func hideEditorBar() {
//        let editorBar = self.editorBar
//        let collectionView = self.collectionView
//
//        guard !editorBar.isHidden else { return }
//
//        var newCollectionViewFrame = collectionView.frame
//        newCollectionViewFrame.origin.y -= editorBar.frame.height
//
//        UIView.animate(withDuration: 0.3, animations: {
//            collectionView.frame = newCollectionViewFrame
//        }, completion: { _ in
//            editorBar.isHidden = true
//        })
//    }
//}
