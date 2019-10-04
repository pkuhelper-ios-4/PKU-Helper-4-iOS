//
//  PHURL.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation

struct PHURL {

    static let developerEmail: String = "zxh2017@pku.edu.cn"
    static let pkuhelperEmail: String = "helper@pku.edu.cn"

    static let pkuEmailURL = URL(string: "https://mail.pku.edu.cn/coremail/hxphone/index.html")!
    static let itsHomeURL = URL(string: "https://its.pku.edu.cn/")!
    static let pzxyCourseHomeURL = URL(string: "https://courses.pinzhixiaoyuan.com/")!

    static let pkuHoleRulesURL = PHBackendAPI.baseURL.appendingPathComponent("/pkuhole/rules.html")
    static let privacyPolicyURL = PHBackendAPI.baseURL.appendingPathComponent("/pkuhelper/privacy_policy.html")
}
