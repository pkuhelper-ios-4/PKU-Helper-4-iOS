//
//  PHBackendAPI+Person.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/14.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire

extension PHBackendAPI {

    enum Person: PHBackendRouter {

        case courseTable(utoken: String)
        case score(utoken: String)
        case unreadEmail(utoken: String)
        case cardBalance(utoken: String)
        case netBalance(utoken: String)

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            switch self {
            case .courseTable:
                return "/pkuhelper/person/course_table"
            case .score:
                return "/pkuhelper/person/score"
            case .unreadEmail:
                return "/pkuhelper/person/unread_email_count"
            case .cardBalance:
                return "/pkuhelper/person/card_balance"
            case .netBalance:
                return "/pkuhelper/person/net_balance"
            }
        }

        var parameters: Parameters? {
            switch self {
            case .courseTable, .score, .unreadEmail, .cardBalance, .netBalance:
                return nil
            }
        }

        var utoken: String? {
            switch self {
            case let .courseTable(utoken):
                return utoken
            case let .score(utoken):
                return utoken
            case let .unreadEmail(utoken):
                return utoken
            case let .cardBalance(utoken):
                return utoken
            case let .netBalance(utoken):
                return utoken
            }
        }
    }
}
