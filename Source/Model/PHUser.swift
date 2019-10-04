//
//  PHUser.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/28.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper
import SwiftyUserDefaults

class PHUser: ImmutableMappable, Codable, DefaultsSerializable {

    enum Gender: String, Codable {
        case male, female, unknown
    }

    let uid: String
    let name: String
    let gender: Gender
    let birthday: String
    let department: String
    let utoken: String
    let uniqueID: Int

    required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        gender = PHUser.parseISOPGender(gender: try map.value("gender"))
        birthday = try map.value("birthday")
        department = try map.value("department")
        utoken = try map.value("utoken")
        uniqueID = try map.value("uniqueID")
    }

    private static func parseISOPGender(gender raw: String) -> Gender {
        if raw == "男" || raw == "男性" {
            return .male
        } else if raw == "女" || raw == "女性" {
            return .female
        } else {
            return .unknown
        }
    }

    static var `default`: PHUser? {
        get {
            return Defaults[.user]
        }
        set {
            Defaults[.user] = newValue
            DefaultsKeys.updatePrefix()
        }
    }
}
