//
//  PHV2PersonBalance.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2PersonBalance: ImmutableMappable {

    let balance: Double

    init(map: Map) throws {
        balance = try map.value("balance")
    }
}
