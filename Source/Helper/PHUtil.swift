//
//  PHUtil.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/15.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation

struct PHUtil {

    //
    // https://github.com/LeoMobileDeveloper/PullToRefreshKit/blob/master/Demo/Demo/Util.swift
    //
    static func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

    static func now() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
}

//
// https://stackoverflow.com/questions/30748480/swift-get-devices-wifi-ip-address
//
extension PHUtil {

    private struct Interfaces {
        static let wifi = ["en0"]
        static let wired = ["en2", "en3", "en4"]
        static let cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
        static let supported = wifi + wired + cellular
    }

    enum IPVersion {
        case ipv4, ipv6
    }

    static func ipAddress(version: IPVersion) -> String? {
        return ipAddress(versions: [version])
    }

    static func ipAddress(versions: [IPVersion]) -> String? {
        var ipAddress: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var pointer = ifaddr

            while pointer != nil {
                defer { pointer = pointer?.pointee.ifa_next }

                guard
                    let interface = pointer?.pointee,
                    (versions.contains(.ipv4) && interface.ifa_addr.pointee.sa_family == UInt8(AF_INET))
                        || (versions.contains(.ipv6) && interface.ifa_addr.pointee.sa_family == UInt8(AF_INET6)),
                    let interfaceName = interface.ifa_name,
                    let interfaceNameFormatted = String(cString: interfaceName, encoding: .utf8),
                    Interfaces.supported.contains(interfaceNameFormatted)
                    else { continue }

                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))

                getnameinfo(interface.ifa_addr,
                            socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            socklen_t(0),
                            NI_NUMERICHOST)

                guard
                    let formattedIpAddress = String(cString: hostname, encoding: .utf8),
                    !formattedIpAddress.isEmpty
                    else { continue }

                ipAddress = formattedIpAddress
                break
            }

            freeifaddrs(ifaddr)
        }

        return ipAddress
    }
}
