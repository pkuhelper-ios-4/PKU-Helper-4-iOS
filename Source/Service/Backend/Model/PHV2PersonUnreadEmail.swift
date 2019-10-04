//
//  PHV2PersonUnreadEmail.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2PersonUnreadEmail: ImmutableMappable {

    let count: Int

    init(map: Map) throws {
        count = try map.value("count")
    }
}
