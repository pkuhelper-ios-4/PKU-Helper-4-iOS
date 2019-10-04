//
//  PHIPGWErrorResponse.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/10/4.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHIPGWErrorResponse: PHIPGWBaseResponse {

    let error: String

    init(map: Map) throws {
        error = try map.value("error")
    }
}
