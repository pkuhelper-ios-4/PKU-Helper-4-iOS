//
//  PHSettingDeveloperOptionsViewController.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/30.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import WatchdogInspector

class PHSettingDeveloperOptionsViewController: PHSettingBaseSubSettingViewController {

    @objc let showFPSSwitcher: UISwitch = {
        let switcher = UISwitch()
        return switcher
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Developer Options (in development)"
    }

    override func setupControls() {
        showFPSSwitcher.isOn = Defaults[.isFPSDetectorOn]
        showFPSSwitcher.addTarget(self, action: #selector(handleShowFPSSwither(_:)), for: .valueChanged)
    }

    @objc func handleShowFPSSwither(_ switcher: UISwitch) {
        Defaults[.isFPSDetectorOn] = switcher.isOn
        if switcher.isOn {
            guard !TWWatchdogInspector.isRunning() else { return }
            TWWatchdogInspector.start()
        } else {
            guard TWWatchdogInspector.isRunning() else { return }
            TWWatchdogInspector.stop()
        }
    }

    override func populateDataSource() -> TableKeys.DataSourceModel {
        return [
            [
                TableKeys.Header: "FPS",
                TableKeys.Rows: [
                    [
                        TableKeys.Title: "FPS detector",
                        TableKeys.AccessoryView: "showFPSSwitcher",
                    ]
                ]
            ]
        ]
    }
}
