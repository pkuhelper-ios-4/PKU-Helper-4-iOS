//
//  PHBackendError.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/10.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire

enum PHBackendError: Error {

    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: AFError)
    case jsonSerialization(error: Error)
    case v2Errcode(errcode: Int, errmsg: String, rid: Int)
}

extension PHBackendError: CustomStringConvertible {

    var description: String {
        switch self {
        case let .network(error):
            return "\(error)"
        case let .dataSerialization(error):
            return "\(error)"
        case let .jsonSerialization(error):
            return "\(error)"
        case let .v2Errcode(code, message, rid):
            return "[\(code)] \(message) (rid: \(rid))"
        }
    }
}

extension PHBackendError {

    enum Errcode: Int {
        case success = 0
        case unknown = -1
        case loginCaptchaExpired = 2003
        case loginBadCaptcha = 2004
        case operationNotAllowed = 2006
        case isopUnauthorized = 2007
        case isopMobileNotFound = 2008
        case pkuHolePostNotFound = 3004
        case pkuHolePostAlreadyReported = 3006
        case pkuHoleUserBeBanned = 3008
        case pkuHolePostAlreadyStarred = 3010
        case pkuHolePostNotStarred = 3011
        case pkuHoleContainsSensitiveWords = 3013
    }
}

