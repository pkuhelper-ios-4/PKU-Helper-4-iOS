//
//  UITextField+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/13.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

// MARK: - Properties
public extension UITextField {

    /// SwifterSwift: Check if text field is empty.
    var isEmpty: Bool {
        return text?.isEmpty == true
    }

    /// SwifterSwift: Return text with no spaces or new lines in beginning and end.
    var trimmedText: String? {
        return text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Methods
public extension UITextField {

    /// SwifterSwift: Clear text.
    func clear() {
        text = ""
        attributedText = NSAttributedString(string: "")
    }

    /// SwifterSwift: Set placeholder text color.
    ///
    /// - Parameter color: placeholder text color.
    func setPlaceHolderTextColor(_ color: UIColor) {
        guard let holder = placeholder, !holder.isEmpty else { return }
        attributedPlaceholder = NSAttributedString(string: holder, attributes: [.foregroundColor: color])
    }

    /// SwifterSwift: Add padding to the left of the textfield rect.
    ///
    /// - Parameter padding: amount of padding to apply to the left of the textfield rect.
    func addPaddingLeft(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }

    /// SwifterSwift: Add padding to the left of the textfield rect.
    ///
    /// - Parameters:
    ///   - image: left image
    ///   - padding: amount of padding between icon and the left of textfield
    func addPaddingLeftIcon(_ image: UIImage, padding: CGFloat) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        leftView = imageView
        leftView?.frame.size = CGSize(width: image.size.width + padding, height: image.size.height)
        leftViewMode = .always
    }
}

