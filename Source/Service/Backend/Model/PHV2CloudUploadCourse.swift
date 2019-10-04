//
//  PHV2CloudUploadCourse.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/22.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2CloudUploadCourse: ImmutableMappable {

    let cid: Int

    init(map: Map) throws {
        cid = try map.value("cid")
    }
}
