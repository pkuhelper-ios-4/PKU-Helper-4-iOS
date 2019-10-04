//
//  PHIPGWAPI+Router.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire

enum PHIPGWRouter: URLRequestConvertible {

    case getMessages
    case getConnections(username: String, password: String)
    case open(username: String, password: String, ip: String)
    case close
    case closeAll(username: String, password: String)
    case disconnect(username: String, password: String, ip: String)

    var parameters: Parameters? {
        switch self {
        case .getMessages:
            return ["cmd": "getmsgs"]
        case let .getConnections(username, password):
            return ["cmd": "getconnections", "username": username, "password": password]
        case let .open(username, password, ip):
            return ["cmd": "open", "username": username, "password": password,
                    "iprange": "free", "ip": ip, "app": PHIPGWAPI.userAgent]
        case .close:
            return ["cmd": "close"]
        case let .closeAll(username, password):
            return ["cmd": "closeall", "username": username, "password": password]
        case let .disconnect(username, password, ip):
            return ["cmd": "disconnect", "username": username, "password": password, "ip": ip]
        }
    }

    func asURLRequest() throws -> URLRequest {
        var urlRequest: URLRequest
        urlRequest = try URLRequest(url: PHIPGWAPI.ITSClientURL, method: .post)
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        return urlRequest
    }
}
