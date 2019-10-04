//
//  PHHoleWriteCommentViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/8.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHHoleWriteCommentViewController: PHHoleTranslucentWritingBaseViewController {

    static let shared = PHHoleWriteCommentViewController()

    var replayName: String? {
        didSet {
            guard inputTextView.text.isEmpty else { return }
            if let name = replayName {
                inputTextView.text = "Re \(name): "
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Write Comment"
        confirmButton.setTitle("Post", for: .normal)
        inputTextView.placeholder = "Enter your comment here ..."
    }

    override func reset() {
        delegate = nil
        replayName = nil
        inputTextView.text = ""
    }
}
