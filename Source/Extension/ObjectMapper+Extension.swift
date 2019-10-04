//
//  ObjectMapper+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/16.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import ObjectMapper

struct JSONIntTransform: TransformType {

    typealias Object = Int
    typealias JSON = Any?

    func transformFromJSON(_ value: Any?) -> Int? {
        guard let json = value else { return nil }
        switch json {
        case let intValue as Int:
            return intValue
        case let stringValue as String:
            return Int(stringValue)
        default:
            return nil
        }
    }

    func transformToJSON(_ value: Int?) -> Any?? {
        guard let object = value else { return nil }
        return String(object)
    }
}


struct JSONRawRepresentableTransform<T: RawRepresentable>: TransformType {

    typealias Object = T
    typealias JSON = Any?

    func transformFromJSON(_ value: Any?) -> T? {
        guard let json = value else { return nil }
        switch json {
        case let rawValue as T.RawValue:
            return T(rawValue: rawValue)
        case let tValue as T:
            return tValue
        default:
            return nil
        }
    }

    func transformToJSON(_ value: T?) -> Any?? {
        return value?.rawValue
    }
}


extension Map {

    ///
    /// transfer JSON null to nil of [Any]?
    ///
    func valueNull2Nil<T: BaseMappable>(_ key: String, nested: Bool? = nil, delimiter: String = ".") throws -> [T]? {
        do {
            return try value(key, nested: nested, delimiter: delimiter)
        } catch {
            if let mapError = error as? MapError, mapError.currentValue == nil {
                return nil
            }
            throw error
        }
    }

    func valueNull2Nil<Transform: TransformType>(_ key: String, nested: Bool? = nil, delimiter: String = ".", using transform: Transform) throws -> [Transform.Object]? {
        do {
            return try value(key, nested: nested, delimiter: delimiter, using: transform)
        } catch {
            if let mapError = error as? MapError, mapError.currentValue == nil {
                return nil
            }
            throw error
        }
    }

    ///
    /// transfer JSON null to nil of Any?
    ///
    func valueNull2Nil<T: BaseMappable>(_ key: String, nested: Bool? = nil, delimiter: String = ".") throws -> T? {
        do {
            return try value(key, nested: nested, delimiter: delimiter)
        } catch {
            if let mapError = error as? MapError, mapError.currentValue == nil {
                return nil
            }
            throw error
        }
    }

    func valueNull2Nil<Transform: TransformType>(_ key: String, nested: Bool? = nil, delimiter: String = ".", using transform: Transform) throws -> Transform.Object? {
        do {
            return try value(key, nested: nested, delimiter: delimiter, using: transform)
        } catch {
            if let mapError = error as? MapError, mapError.currentValue == nil {
                return nil
            }
            throw error
        }
    }
}
