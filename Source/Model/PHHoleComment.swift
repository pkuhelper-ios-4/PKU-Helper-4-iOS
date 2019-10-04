//
//  PHHoleComment.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

class PHHoleComment: ImmutableMappable {

    let cid: Int
    let pid: Int
    let content: String
    let timestamp: Int
    let tag: String?
    let name: String

    weak var post: PHHolePost?

    var isOriginalPoster: Bool {
        return name == "洞主"
    }

    required init(map: Map) throws {
        cid = try map.value("cid")
        pid = try map.value("pid")
        content = try map.value("text")
        timestamp = try map.value("timestamp")
        tag = try map.value("tag")
        name = try map.value("name")
    }
}

extension PHHoleComment: Equatable {

    static func == (lhs: PHHoleComment, rhs: PHHoleComment) -> Bool {
        return lhs.cid == rhs.cid
    }
}

extension Array where Element == PHHoleComment {

    mutating func sortByTimestamp(ascending: Bool = true) {
        self.sort { lhs, rhs in
            if lhs.timestamp == rhs.timestamp {
                return ascending ? lhs.cid < rhs.cid : lhs.cid > rhs.cid
            } else {
                return ascending ? lhs.timestamp < rhs.timestamp : lhs.timestamp > rhs.timestamp
            }
        }
    }

    func sortedByTimestamp(ascending: Bool = true) -> [Element] {
        return self.sorted { lhs, rhs in
            if lhs.timestamp == rhs.timestamp {
                return ascending ? lhs.cid < rhs.cid : lhs.cid > rhs.cid
            } else {
                return ascending ? lhs.timestamp < rhs.timestamp : lhs.timestamp > rhs.timestamp
            }
        }
    }
}
