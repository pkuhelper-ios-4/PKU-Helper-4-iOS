//
//  PHBackendAPI+Base.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/22.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire

extension PHBackendAPI {

    enum Base: PHBackendRouter {

        case getTimestamp
        case getSemesterBeginning
        case getFeature

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            switch self {
            case .getTimestamp:
                return "/get_timestamp"
            case .getSemesterBeginning:
                return "/pkuhelper/date/semester_beginning"
            case .getFeature:
                return "/pkuhelper/feature"
            }
        }
    }
}
