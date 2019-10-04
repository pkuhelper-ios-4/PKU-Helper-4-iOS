//
//  PHIPGWGetConnections.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper
import SwiftDate

struct PHIPGWGetConnections: PHIPGWBaseResponse {

    let connections: [PHIPGWConnection]

    init(map: Map) throws {
        connections = try PHIPGWGetConnections.parseConnections(try map.value("succ"))
    }

    private static func parseConnections(_ succ: String) throws -> [PHIPGWConnection] {
        guard !succ.isEmpty else { return [] }

        let fields = succ.split(separator: ";")

        guard fields.count % 4 == 0 else {
            throw PHIPGWError.ipgwResponseInvalidFormat(key: "succ", value: succ)
        }

        let length = Int(fields.count/4)

        do {
            return try (0..<length).map { row in
                let ip = String(fields[row * 4 + 0])
                let type = String(fields[row * 4 + 1])
                let site = String(fields[row * 4 + 2])
                let time = String(fields[row * 4 + 3]) // "yyyy-MM-dd HH:mm:ss"
                guard let timestamp = time.toDate(nil, region: PHGlobal.regionBJ)?.timeIntervalSince1970 else {
                    throw PHIPGWError.ipgwResponseInvalidFormat(key: "succ", value: succ)
                }
                return PHIPGWConnection(ip: ip, site: site, type: type, timestamp: timestamp)
            }
        } catch {
            throw error
        }
    }
}
