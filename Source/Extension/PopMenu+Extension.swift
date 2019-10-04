//
//  PopMenu+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import PopMenu

extension PopMenuManager {

    public func present(
        navItem: UINavigationItem,  // From navigationItem.rightBarButtonItem
        on viewController: UIViewController? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil) {

        guard let button = navItem.value(forKey: "view") as? UIView else {
            present(sourceView: nil, on: viewController, animated: animated, completion: completion)
            return
        }

        let absFrame = button.convert(button.frame, to: nil)
        let newOrigin = CGPoint(x: absFrame.origin.x, y: absFrame.origin.y + absFrame.height)

        let sourceView = UIView(frame: CGRect(origin: newOrigin, size: .zero))
        UIApplication.shared.keyWindow?.addSubview(sourceView)

        present(sourceView: sourceView, on: viewController, animated: animated) {
            sourceView.removeFromSuperview()
            completion?()
        }
    }

}
