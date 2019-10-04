//
//  PHV2PersonScore.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/14.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2PersonScore: ImmutableMappable {

    let scores: PHOverallScore

    init(map: Map) throws {
        scores = try map.value("scores")
    }
}
