//
//  PHSettingPKUHoleViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/11.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class PHSettingPKUHoleViewController: PHSettingBaseSubSettingViewController {

    @objc let showRelativeDateSwitcher: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "PKU Hole"
    }

    override func setupControls() {
        showRelativeDateSwitcher.isOn = Defaults[.pkuHoleDefaultShowRelativeDate]
        showRelativeDateSwitcher.addTarget(self, action: #selector(handleshowRelativeDateSwitcher(_:)), for: .valueChanged)
    }

    @objc func handleshowRelativeDateSwitcher(_ switcher: UISwitch) {
        Defaults[.pkuHoleDefaultShowRelativeDate] = switcher.isOn
    }

    override func populateDataSource() -> TableKeys.DataSourceModel {
        return  [
            [
                TableKeys.Header: "Defaults",
                TableKeys.Rows: [
                    [
                        TableKeys.Title: "Show relative date",
                        TableKeys.AccessoryView: "showRelativeDateSwitcher",
                    ]
                ]
            ]
        ]
    }
}
