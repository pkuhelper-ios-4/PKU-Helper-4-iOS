//
//  PHV2ResponseStatus.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/13.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2ResponseStatus: ImmutableMappable {

    let errcode: Int
    let errmsg: String
    let rid: Int

    init(map: Map) throws {
        errcode = try map.value("errcode")
        errmsg = try map.value("errmsg")
        rid = try map.value("rid")
    }
}
