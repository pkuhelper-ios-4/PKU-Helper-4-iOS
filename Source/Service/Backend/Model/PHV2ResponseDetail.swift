//
//  PHV2ResponseDetail.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/12.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2ResponseDetail<T: BaseMappable>: ImmutableMappable {

    let detail: T

    init(map: Map) throws {
        detail = try map.value("detail")
    }
}
