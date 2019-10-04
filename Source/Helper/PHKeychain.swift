//
//  PHKeychain.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/31.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import SwiftyUserDefaults
import KeychainSwift

struct PHKeychain {

    static var iaaaPassword: String? {
        get {
            return keychain.get(keyForIAAAPassword)
        }
        set {
            if let password = newValue {
                keychain.set(password, forKey: keyForIAAAPassword)
            } else {
                keychain.delete(keyForIAAAPassword)
            }
        }
    }
}

extension PHKeychain {

    static let keychain = KeychainSwift()

    fileprivate static var prefix: String {
        return DefaultsKeys.prefix
    }

    fileprivate static var keyForIAAAPassword: String {
        return "\(prefix)_iaaa_password"
    }
}
