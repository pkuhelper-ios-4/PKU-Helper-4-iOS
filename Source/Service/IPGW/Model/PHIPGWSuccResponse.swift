//
//  PHIPGWSuccResponse.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHIPGWSuccResponse: PHIPGWBaseResponse {

    let succ: String

    init(map: Map) throws {
        succ = try map.value("succ")
    }
}

typealias PHIPGWGetMessages = PHIPGWSuccResponse
typealias PHIPGWClose = PHIPGWSuccResponse
typealias PHIPGWCloseAll = PHIPGWSuccResponse
typealias PHIPGWDisconnect = PHIPGWSuccResponse
