//
//  PHIPGWStatus.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import SwiftyUserDefaults

class PHIPGWStatus: Codable, DefaultsSerializable {

    let ip: String
    let connections: Int
    let balance: Double
    let timestamp: TimeInterval

    init(from response: PHIPGWOpen) {
        ip = response.ip
        connections = response.connections
        balance = response.balance
        timestamp = PHUtil.now()
    }

    // create dummy status
    private init() {
        ip = "-"
        connections = 0
        balance = 0.0
        timestamp = 0.0
    }

    // singleton dummy instance
    static let dummy = PHIPGWStatus()

    func isDummy() -> Bool { return self === PHIPGWStatus.dummy }
}

extension PHIPGWStatus: CustomStringConvertible {

    var description: String {
        return """
        IPGW Status:
        IP: \(ip)
        Connections: \(connections)
        Balance: \(balance)
        Timestamp: \(timestamp)
        """
    }
}

