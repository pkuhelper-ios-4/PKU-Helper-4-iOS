//
//  PHV2MessageUnreadCount.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/15.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2MessageUnreadCount: ImmutableMappable {

    let count: Int

    init(map: Map) throws {
        count = try map.value("count")
    }
}
