//
//  PHBackendAPI+Login.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/12.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire

extension PHBackendAPI {

    enum Login: PHBackendRouter {

        enum ValidcodeReceiver: String {
            case mobile, email
        }

        case getMobile(uid: String)
        case getCaptchaForSendingValidcode(uid: String)
        case sendValidcode(uid: String, captcha: String, receiver: ValidcodeReceiver)
        case isopLogin(uid: String, validCode: String)

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            switch self {
            case .getMobile:
                return "/pkuhelper/login/get_mobile"
            case .getCaptchaForSendingValidcode:
                return "/pkuhelper/login/get_captcha"
            case .sendValidcode:
                return "/pkuhelper/login/send_validcode"
            case .isopLogin:
                return "/pkuhelper/login/"
            }
        }

        var parameters: Parameters? {
            switch self {
            case let .getMobile(uid):
                return ["uid": uid]
            case let .getCaptchaForSendingValidcode(uid):
                return ["uid": uid]
            case let .sendValidcode(uid, captcha, receiver):
                return ["uid": uid, "captcha": captcha, "type": receiver.rawValue]
            case let .isopLogin(uid, validCode):
                return ["uid": uid, "validCode": validCode, "platform": "iOS"]
            }
        }
    }
}

