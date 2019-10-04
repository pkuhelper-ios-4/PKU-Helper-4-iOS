//
//  PHHolePost.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

class PHHolePost: ImmutableMappable {

    enum PostType: String {
        case text, image, audio
    }

    let pid: Int
    let content: String
    let type: PostType
    let timestamp: Int
    var commentCount: Int
    var starCount: Int
    let staticFilename: String
    let tag: String?
    var reported: Bool
    var starred: Bool
    var comments: [PHHoleComment]?

    required init(map: Map) throws {
        pid = try map.value("pid")
        content = try map.value("text")
        type = try map.value("type")
        timestamp = try map.value("timestamp")
        commentCount = try map.value("reply")
        starCount = try map.value("likenum")
        staticFilename = try map.value("url")
        tag = try map.value("tag")
        reported = try map.value("report")
        starred = try map.value("attention")
        comments = try map.valueNull2Nil("comments")
        comments?.forEach { $0.post = self }
    }

    var image: PHBackendAPI.Image? {
        guard type == .image else { return nil }
        guard let filename = staticFilename.trimmed.empty2Nil() else { return nil }
        guard let image = PHBackendAPI.Image(filename: filename) else { return nil }
        return image
    }
}

extension PHHolePost {

    func switchStar(to state: Bool) {
        if state {
            starred = true
            starCount += 1
        } else {
            starred = false
            starCount -= 1
            if starCount < 0 {
                starCount = 0
            }
        }
    }
}

extension PHHolePost: Equatable {

    static func == (lhs: PHHolePost, rhs: PHHolePost) -> Bool {
        return lhs.pid == rhs.pid
    }
}

extension Array where Element == PHHolePost {

    func sortedByTimestamp(ascending: Bool = true) -> [Element] {
        return self.sorted { lhs, rhs in
            if lhs.timestamp == rhs.timestamp {
                return ascending ? lhs.pid < rhs.pid : lhs.pid > rhs.pid
            } else {
                return ascending ? lhs.timestamp < rhs.timestamp : lhs.timestamp > rhs.timestamp
            }
        }
    }

    func sortedByPid(ascending: Bool = true) -> [Element] {
        return self.sorted { lhs, rhs in
            return ascending ? lhs.pid < rhs.pid : lhs.pid > rhs.pid
        }
    }

    func maxPid() -> Int? {
        return self.max(by: { $0.pid < $1.pid })?.pid
    }

    func minPid() -> Int? {
        return self.min(by: { $0.pid < $1.pid })?.pid
    }

    func get(_ pid: Int) -> PHHolePost? {
        return self.first(where: { $0.pid == pid })
    }
}
