//
//  PHV2MessageList.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/14.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2MessageList: ImmutableMappable {

    let messages: [PHMessage]

    init(map: Map) throws {
        messages = try map.value("messages")
    }
}
