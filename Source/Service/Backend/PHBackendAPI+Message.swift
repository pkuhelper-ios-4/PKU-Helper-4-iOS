//
//  PHBackendAPI+Message.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/14.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire

extension PHBackendAPI {

    enum Message: PHBackendRouter {

        case publicList
        case personListByStartMid(mid: Int?, utoken: String)
        case personUnreadCount(utoken: String)
        case personSetHasread(mid: Int, utoken: String)
        case personDelete(mid: Int, utoken: String)

        var method: HTTPMethod {
            switch self {
            case .publicList, .personListByStartMid, .personUnreadCount:
                return .get
            case .personSetHasread, .personDelete:
                return .post
            }
        }

        var path: String {
            switch self {
            case .publicList:
                return "/message/public/list"
            case .personListByStartMid:
                return "/message/person/list_by_start_mid"
            case .personUnreadCount:
                return "/message/person/unread_count"
            case .personSetHasread:
                return "/message/person/set_hasread"
            case .personDelete:
                return "/message/person/delete"
            }
        }

        var parameters: Parameters? {
            switch self {
            case .publicList, .personUnreadCount:
                return nil
            case let .personListByStartMid(mid, _):
                return ["mid": mid ?? ""]
            case let .personSetHasread(mid, _):
                return ["mid": mid]
            case let .personDelete(mid, _):
                return ["mid": mid]
            }
        }

        var utoken: String? {
            switch self {
            case .publicList:
                return nil
            case let .personListByStartMid(_, utoken):
                return utoken
            case let .personUnreadCount(utoken):
                return utoken
            case let .personSetHasread(_ ,utoken):
                return utoken
            case let .personDelete(_, utoken):
                return utoken
            }
        }
    }
}
