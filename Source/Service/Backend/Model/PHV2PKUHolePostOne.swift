//
//  PHV2PKUHolePostOne.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/16.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2PKUHolePostOne: ImmutableMappable {

    let post: PHHolePost?

    init(map: Map) throws {
        post = try map.valueNull2Nil("post")
    }
}
