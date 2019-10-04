//
//  PHV2LoginGetMobile.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/12.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2LoginGetMobile: ImmutableMappable {

    let mobile: String

    init(map: Map) throws {
        mobile = try map.value("mobile")
    }
}
