//
//  PHHoleWelcomeViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SafariServices

protocol PHHoleWelcomeViewControllerDelegate: AnyObject {

    func welcomeViewDidDisappear(_ controller: PHHoleWelcomeViewController)
}

extension PHHoleWelcomeViewControllerDelegate {

    func welcomeViewDidDisappear(_ controller: PHHoleWelcomeViewController) {}
}

class PHHoleWelcomeViewController: PHBaseViewController {

    weak var delegate: PHHoleWelcomeViewControllerDelegate?

    let contentLabel: UILabel = {
        let label = UILabel()
        label.font = PHGlobal.font.regular
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = """
        Hello! Welcome to PKU Hole.

        Before using PKU Hole, you need to accept our terms of PKU Hole.

        You can visit our terms by clicking the button below

        If you want to visit this terms in the future, go to homepage, click the 'Settings' button in the upper right corner, then click the 'Terms of PKU Hole' in the last section.

        """
        return label
    }()

    let termsLinkButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = PHGlobal.font.regular
        button.setTitle("Terms of PKU Hole", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()

    let agreeButton: UIButton = {
        let button = UIButton()
        button.setTitle("I accept the terms", for: .normal)
        button.setTitle("I don't accept the terms", for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.backgroundColor = .blue
        return button
    }()

    var hasAgreedTerms: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Welcome to PKU Hole"

        view.backgroundColor = .white

        view.addSubviews([contentLabel, termsLinkButton, agreeButton])

        let sideSpacing = PHGlobal.screenWidth * 0.08
        let lineSpacing = PHGlobal.font.regular.pointSize * 2
        let buttonHeight = PHGlobal.font.regular.pointSize * 2.5

        contentLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.equalToSuperview().offset(PHGlobal.topBarsHeight + lineSpacing * 1.5)
        }

        termsLinkButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(sideSpacing)
            make.right.lessThanOrEqualToSuperview().inset(sideSpacing)
            make.top.equalTo(contentLabel.snp.bottom).offset(lineSpacing * 0.5)
            make.height.equalTo(buttonHeight)
        }

        agreeButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(sideSpacing)
            make.top.equalTo(termsLinkButton.snp.bottom).offset(lineSpacing)
            make.height.equalTo(buttonHeight)
        }

        termsLinkButton.addTarget(self, action: #selector(termsLinkButtonTapped(_:)), for: .touchUpInside)
        agreeButton.addTarget(self, action: #selector(agreeButtonTapped(_:)), for: .touchUpInside)

        agreeButton.isEnabled = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.welcomeViewDidDisappear(self)
    }

    @objc func termsLinkButtonTapped(_ button: UIButton) {
        let safari = SFSafariViewController(url: PHBackendAPI.baseURL.appendingPathComponent("/pkuhole/rules.html"))
        safari.delegate = self
        present(safari, animated: true, completion: nil)
    }

    @objc func agreeButtonTapped(_ button: UIButton) {
        hasAgreedTerms = true
        navigationController?.popViewController()
    }
}

extension PHHoleWelcomeViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
        agreeButton.isEnabled = true
    }
}
