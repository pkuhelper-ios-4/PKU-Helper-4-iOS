//
//  PHTestPopMenuViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/7.
//  Copyright © 2019 PKUHelper. All rights reserved.
//
/**
import UIKit
import PopMenu

class PHTestPopMenuViewController: PHBaseViewController {

//    let popMenuController: PopMenuViewController = {
//        let controller = PopMenuViewController()
//        controller.addAction(PopMenuDefaultAction(title: "item1", image: R.image.settings(), color: .red))
//        controller.addAction(PopMenuDefaultAction(title: "item2", image: R.image.about(), color: .blue, didSelect: nil))
//        return controller
//    }()

    let toggleButton: UIButton = {
        let button = UIButton()
        button.setTitle("pop menu", for: .normal)
        button.backgroundColor = .blue
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        toggleButton.addTarget(self, action: #selector(PHTestPopMenuViewController.toggleButtonTapped(sender:)), for: .touchUpInside)

        view.addSubview(toggleButton)
        toggleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(100)
            make.size.equalTo(CGSize(width: 120, height: 40))
        }

    }

    @objc func toggleButtonTapped(sender: UIButton) {

        let actions = [
            PopMenuDefaultAction(title: "item1", image: R.image.settings()),
            PopMenuDefaultAction(title: "item2", image: R.image.about()),
        ]

        let popMenuController = PopMenuViewController(sourceView: sender, actions: actions)
        popMenuController.appearance.popMenuBackgroundStyle = .blurred(.light)
        popMenuController.appearance.popMenuColor.backgroundColor = .solid(fill: .gray)
        popMenuController.appearance.popMenuColor.actionColor = .tint(.white)
        popMenuController.appearance.popMenuCornerRadius = 0
        popMenuController.appearance.popMenuFont = PHGlobal.font.regularBold

        present(popMenuController, animated: true, completion: nil)
    }

}
**/
