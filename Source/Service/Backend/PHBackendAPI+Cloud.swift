//
//  PHBackendAPI+Cloud.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/22.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire
import ObjectMapper

extension PHBackendAPI {

    enum Cloud: PHBackendRouter {

        case uploadCourse(course: PHCourse, utoken: String)
        case getAllCourses(utoken: String)
        case deleteCourse(cid: Int, utoken: String)

        var method: HTTPMethod {
            switch self {
            case .uploadCourse, .deleteCourse:
                return .post
            case .getAllCourses:
                return .get
            }
        }

        var path: String {
            switch self {
            case .uploadCourse:
                return "/pkuhelper/cloud/course/upload"
            case .getAllCourses:
                return "/pkuhelper/cloud/course/all"
            case .deleteCourse:
                return "/pkuhelper/cloud/course/delete"
            }
        }

        var parameters: Parameters? {
            switch self {
            case .uploadCourse: // course will be send as json string
                return nil
            case .getAllCourses:
                return nil
            case let .deleteCourse(cid, _):
                return ["cid": cid]
            }
        }

        var utoken: String? {
            switch self {
            case let .uploadCourse(_, utoken):
                return utoken
            case let .getAllCourses(utoken):
                return utoken
            case let .deleteCourse(_, utoken):
                return utoken
            }
        }

        func customURLRequest(_ urlRequest: URLRequest) throws -> URLRequest {
            switch self {
            case let .uploadCourse(course, _):
                return try JSONEncoding.default.encode(urlRequest, withJSONObject: course.toJSON())
            default:
                return urlRequest
            }
        }
    }
}
