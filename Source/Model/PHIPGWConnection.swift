//
//  PHIPGWConnection.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation

class PHIPGWConnection {

    let ip: String
    let site: String
    let type: String
    let timestamp: TimeInterval

    init(ip: String, site: String, type: String, timestamp: TimeInterval) {
        self.ip = ip
        self.site = site
        self.type = type
        self.timestamp = timestamp
    }
}
