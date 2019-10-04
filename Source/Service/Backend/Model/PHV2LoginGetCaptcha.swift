//
//  PHV2LoginGetCaptcha.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/12.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2LoginGetCaptcha: ImmutableMappable {

    let expires: Int
    let captcha: PHV2LoginCaptcha

    init(map: Map) throws {
        expires = try map.value("expires")
        captcha = try map.value("captcha")
    }
}
