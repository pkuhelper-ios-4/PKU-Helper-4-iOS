//
//  PHAlert.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/9.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import PopupDialog

struct PHAlert {

    static var successHeaderImage: UIImage? {
        let icon = R.image.ok()?.filled(withColor: UIColor.Material.greenA700)
        return getHeaderIamge(icon)
    }

    static var infoHeaderImage: UIImage? {
        let icon = R.image.info()?.filled(withColor: .blue)
        return getHeaderIamge(icon)
    }

    static var warningHeaderImage: UIImage? {
        let icon = R.image.attention()?.filled(withColor: UIColor.Material.yellowA700)
        return getHeaderIamge(icon)
    }

    static var errorHeaderImage: UIImage? {
        let icon = R.image.error()?.filled(withColor: .red)
        return getHeaderIamge(icon)
    }

    let viewController: UIViewController!

    init?(on viewController: UIViewController?) {
        guard let strongViewController = viewController else { return nil }
        self.viewController = strongViewController
    }

    func popup(title: String?,
               message: String?,
               image: UIImage? = nil,
               completion: (() -> Void)? = nil) {

        let presentClosure = {

            // MARK: setup messageTextAlignment

            let dialogAppearance = PopupDialogDefaultView.appearance()
            if let _message = message, _message.widthOfString(usingFont: dialogAppearance.messageFont) > 300 {
                dialogAppearance.messageTextAlignment = .left
            } else {
                dialogAppearance.messageTextAlignment = .center
            }

            let popup = PopupDialog(title: title,
                                    message: message,
                                    image: image,
                                    transitionStyle: .fadeIn,
                                    completion: completion)

            let okButton = DefaultButton(title: "OK", action: nil)

            popup.addButton(okButton)
            self.viewController.present(popup, animated: true, completion: nil)
        }

        if let previewPopup = viewController.presentedViewController {
            previewPopup.dismiss(animated: false, completion: presentClosure)
        } else {
            presentClosure()
        }
    }

    func success(title: String? = "Success", message: String?, completion: (() -> Void)? = nil) {
        popup(title: title, message: message, image: PHAlert.successHeaderImage, completion: completion)
    }

    func info(title: String? = "Information", message: String?, completion: (() -> Void)? = nil) {
        popup(title: title, message: message, image: PHAlert.infoHeaderImage, completion: completion)
    }

    func warning(title: String? = "Warning", message: String?, completion: (() -> Void)? = nil) {
        popup(title: title, message: message, image: PHAlert.warningHeaderImage, completion: completion)
    }

    func error(title: String? = "An Error Occured", message: String?, completion: (() -> Void)? = nil) {
        debugPrint(message as Any)
        popup(title: title, message: message, image: PHAlert.errorHeaderImage, completion: completion)
    }

    func error(error: Error, completion: (() -> Void)? = nil) {
        self.error(title: "An Error Occured",
                   message: error.localizedDescription,
                   completion: completion)
    }

    func backendError(_ error: PHBackendError, completion: (() -> Void)? = nil) {
        self.error(title: "An Error Occured",
                   message: error.description,
                   completion: completion)
    }

    func ipgwError(_ error: PHIPGWError, completion: (() -> Void)? = nil) {
        self.error(title: "An Error Occured",
                   message: error.description,
                   completion: completion)
    }

    func infoLoginRequired(completion: (() -> Void)? = nil) {
        self.info(title: "Need to login first",
                  message: "This service requires your login credential.",
                  completion: completion)
    }

    func infoISOPTokenExpired(completion: (() -> Void)? = nil) {
        self.info(title: "Need to login again",
                  message: "Your ISOP login credential has expired. Try to login again.",
                  completion: completion)
    }

    func infoPostNotFound(completion: (() -> Void)? = nil) {
        self.info(title: "Post not found",
                  message: "This post may have already been deleted.",
                  completion: completion)
    }

    func infoUserBeBanned(completion: (() -> Void)? = nil) {
        self.info(title: "Failed to post",
                  message: "You have been banned, you will not be able to post or comment before lifting the ban.",
                  completion: completion)
    }

    func infoContainSensitiveWords(completion: (() -> Void)? = nil) {
        self.info(title: "Failed to post",
                  message: "Your post/comment was rejected by server due to containing sensitive words.",
                  completion: completion)
    }

    func warningOperationFailed(message: String?, completion: (() -> Void)? = nil) {
        self.warning(title: "Operation Failed",
                     message: message,
                     completion: completion)
    }

    func warningOperationNotAllowed(completion: (() -> Void)? = nil) {
        self.warningOperationFailed(message: "This operation was rejected by the server.",
                                    completion: completion)
    }

    static func getHeaderIamge(_ image: UIImage?, opaque: Bool = false) -> UIImage? {
        guard let image = image else { return nil }
        let headerImageSize = CGSize(width: 340, height: 140)
        guard image.size.aspectRatio < headerImageSize.aspectRatio else { return image }
        let newImageSize = image.size.aspectFit(to: headerImageSize) * 0.8
        let newImageOrigin = CGPoint(x: (headerImageSize.width - newImageSize.width) / 2, y: headerImageSize.height - newImageSize.height) // center bottom
        UIGraphicsBeginImageContextWithOptions(headerImageSize, opaque, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(in: CGRect(origin: newImageOrigin, size: newImageSize))
        let headerImage = UIGraphicsGetImageFromCurrentImageContext()
        return headerImage
    }
}
