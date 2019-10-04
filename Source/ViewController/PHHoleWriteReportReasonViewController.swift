//
//  PHHoleWriteReportReasonViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/17.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHHoleWriteReportReasonViewController: PHHoleTranslucentWritingBaseViewController {

    static let shared = PHHoleWriteReportReasonViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Write Report Reason"
        confirmButton.setTitle("Submit", for: .normal)
        inputTextView.placeholder = "Enter your reason here ..."
    }

    override func reset() {
        delegate = nil
        inputTextView.text = ""
    }
}
