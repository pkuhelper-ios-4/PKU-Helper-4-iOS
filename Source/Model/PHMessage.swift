//
//  PHMessage.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/7/29.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

class PHMessage: ImmutableMappable {
    
    let mid: Int
    let content: String
    var hasread: Bool
    let timestamp: Int

    required init(map: Map) throws {
        mid = try map.value("mid")
        content = try map.value("text")
        hasread = try map.value("hasread")
        timestamp = try map.value("timestamp")
    }
}

extension PHMessage: Equatable {

    static func == (lhs: PHMessage, rhs: PHMessage) -> Bool {
        return lhs.mid == rhs.mid
    }
}

extension Array where Element == PHMessage {

    func sortedByHasreadAndTime() -> [Element] {
        return self.sorted { lhs, rhs in
            if lhs.hasread != rhs.hasread {
                return !lhs.hasread
            } else {
                return lhs.timestamp > rhs.timestamp
            }
        }
    }

    func minMin() -> Int? {
        return self.min(by: { $0.mid < $1.mid })?.mid
    }
}
