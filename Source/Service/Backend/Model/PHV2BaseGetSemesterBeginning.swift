
//
//  PHV2BaseGetSemesterBeginning.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2BaseGetSemesterBeginning: ImmutableMappable {

    let year: Int
    let month: Int
    let day: Int

    var date: Date {
        return Date(year: year, month: month, day: day, hour: 0, minute: 0)
    }

    init(map: Map) throws {
        year = try map.value("year")
        month = try map.value("month")
        day = try map.value("day")
    }
}
