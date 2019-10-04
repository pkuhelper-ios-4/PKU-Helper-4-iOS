//
//  PHV2PKUHolePostList.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/16.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2PKUHolePostList: ImmutableMappable {

    let posts: [PHHolePost]

    init(map: Map) throws {
        posts = try map.value("posts")
    }
}
