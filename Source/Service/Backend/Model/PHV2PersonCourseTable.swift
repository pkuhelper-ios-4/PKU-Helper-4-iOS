//
//  PHV2PersonCourseTable.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/14.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2PersonCourseTable: ImmutableMappable {

    let courses: [PHCourse]

    init(map: Map) throws {
        courses = try map.value("courses")
    }
}
