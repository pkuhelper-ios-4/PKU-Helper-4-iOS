//
//  PHBackendAPI+PKUHole.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/15.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire

extension PHBackendAPI {

    enum PKUHole: PHBackendRouter {

        case listPostByStartPid(pid: Int?, utoken: String)
        case listPostByEndPid(pid: Int?, utoken: String)
        case listAttention(startPid: Int?, utoken: String)
        case getPost(pid: Int, utoken: String)
        case getLatestPid(utoken: String)
        case searchPost(keywords: String, startPid: Int?, utoken: String)
        case switchPostAttention(pid: Int, state: Bool, utoken: String)  // star/unstar
        case submitComment(pid: Int, text: String, utoken: String)
        case submitReport(pid: Int, reason: String, utoken: String)
        case submitPost(text: String, type: PHHolePost.PostType, utoken: String) // image will be add on multipart

        var method: HTTPMethod {
            switch self {
            case .listPostByStartPid, .listPostByEndPid, .listAttention, .getPost, .getLatestPid,
                 .searchPost:
                return .get
            case .switchPostAttention, .submitComment, .submitReport, .submitPost:
                return .post
            }
        }

        var path: String {
            switch self {
            case .listPostByStartPid:
                return "/pkuhole/post/list_by_start_pid"
            case .listPostByEndPid:
                return "/pkuhole/post/list_by_end_pid"
            case .listAttention:
                return "/pkuhole/attention/list"
            case .getPost:
                return "/pkuhole/post/get"
            case .getLatestPid:
                return "/pkuhole/post/get_latest_pid"
            case .searchPost:
                return "/pkuhole/post/search"
            case .switchPostAttention:
                return "/pkuhole/attention/switch_to"
            case .submitComment:
                return "/pkuhole/comment/submit"
            case .submitReport:
                return "/pkuhole/report/submit"
            case .submitPost:
                return "/pkuhole/post/submit"
            }
        }

        var parameters: Parameters? {
            switch self {
            case let .listPostByStartPid(pid, _):
                return ["pid": pid ?? ""]
            case let .listPostByEndPid(pid, _):
                return ["pid": pid ?? ""]
            case let .listAttention(startPid, _):
                return ["start_pid": startPid ?? ""]
            case let .getPost(pid, _):
                return ["pid": pid, "with_comment": 1] // only getPost will set with_comment = 1
            case .getLatestPid:
                return nil
            case let .searchPost(keywords, startPid, _):
                return ["keywords": keywords, "start_pid": startPid ?? "", "size": 100] // use max size
            case let .switchPostAttention(pid, state, _):
                return ["pid": pid, "state": state]
            case let .submitComment(pid, text, _):
                return ["pid": pid, "text": text]
            case let .submitReport(pid, reason, _):
                return ["pid": pid, "reason": reason]
            case let .submitPost(text, type, _):
                return ["text": text, "type": type.rawValue]
            }
        }

        var utoken: String? {
            switch self {
            case let .listPostByStartPid(_, utoken):
                return utoken
            case let .listPostByEndPid(_, utoken):
                return utoken
            case let .getPost(_, utoken):
                return utoken
            case let .getLatestPid(utoken):
                return utoken
            case let .listAttention(_, utoken):
                return utoken
            case let .searchPost(_, _, utoken):
                return utoken
            case let .switchPostAttention(_, _, utoken):
                return utoken
            case let .submitComment(_, _, utoken):
                return utoken
            case let .submitReport(_, _, utoken):
                return utoken
            case let .submitPost(_, _, utoken):
                return utoken
            }
        }
    }
}
