//
//  PHIPGWOpen.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

//
// https://github.com/wlyPKU/HttpClientForLinux
//
struct PHIPGWOpen: PHIPGWBaseResponse {

    let ip: String
    let connections: Int
    let balance: Double

    init(map: Map) throws {
        ip = try map.value("IP")
        connections = PHIPGWOpen.parseConnections(try map.value("CONNECTIONS"))
        balance = PHIPGWOpen.parseBalance(try map.value("BALANCE_EN"))
    }

    static private func parseConnections(_ raw: String) -> Int {
        return raw.int ?? 0
    }

    static private func parseBalance(_ raw: String) -> Double {
        return raw.double() ?? -1.0
    }
}
