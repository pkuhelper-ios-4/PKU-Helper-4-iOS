//
//  PHV2BaseGetTimestamp.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/12.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2BaseGetTimestamp: ImmutableMappable {

    let timestamp: Double

    init(map: Map) throws {
        timestamp = try map.value("timestamp")
    }
}
