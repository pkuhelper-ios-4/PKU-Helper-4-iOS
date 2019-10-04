//
//  PHV2LoginCaptcha.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/12.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct PHV2LoginCaptcha: ImmutableMappable {

    let width: Int
    let height: Int
    let mode: String
    let format: String
    let imageBase64: String

    init(map: Map) throws {
        width = try map.value("size.0")
        height = try map.value("size.1")
        mode = try map.value("mode")
        format = try map.value("format")
        imageBase64 = try map.value("data")
    }

    var captchaImage: UIImage? {
        guard let decodedData = Data(base64Encoded: imageBase64, options: .ignoreUnknownCharacters) else { return nil }
        return UIImage(data: decodedData)
    }
}
