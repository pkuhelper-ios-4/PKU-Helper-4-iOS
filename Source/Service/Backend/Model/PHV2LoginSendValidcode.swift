//
//  PHV2LoginSendValidcode.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/13.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2LoginSendValidcode: ImmutableMappable {

    var message: String

    init(map: Map) throws {
        message = try map.value("msg")
    }
}
