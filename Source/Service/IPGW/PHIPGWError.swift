//
//  PHIPGWError.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire

enum PHIPGWError: Error {

    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: AFError)
    case jsonSerialization(error: Error)

    case ipgwResponseInvalidFormat(key: String, value: String)
    case ipgwError(message: String)
}

extension PHIPGWError: CustomStringConvertible {

    var description: String {
        switch self {
        case let .network(error):
            return "\(error)"
        case let .dataSerialization(error):
            return "\(error)"
        case let .jsonSerialization(error):
            return "\(error)"
        case let .ipgwResponseInvalidFormat(key, value):
            return "Invalid IPGW Response.\nkey: \(key)\nvalue: \(value)"
        case let .ipgwError(message):
            return "IPGW Error: \(message)"
        }
    }
}
