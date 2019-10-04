//
//  PHNavigationController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/6.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit

class PHNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.titleTextAttributes = [
            .font: PHGlobal.font.largeBold
        ]
    }
}
