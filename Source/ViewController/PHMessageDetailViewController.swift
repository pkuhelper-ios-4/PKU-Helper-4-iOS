//
//  PHMessageDetailViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHMessageDetailViewController: PHBaseViewController {

    let detailView = PHMessageDetailView()

    var message: PHMessage! {
        didSet {
            detailView.message = message
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Message Detail"

        view.addSubview(detailView)

        detailView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(PHGlobal.topBarsHeight)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
