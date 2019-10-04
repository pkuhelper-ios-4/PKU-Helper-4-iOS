//
//  PHPostMemo.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/2.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class PHPostMemo: Codable, DefaultsSerializable {

    var content: String? = nil

    var image: UIImage? {
        get {
            guard let data = imageData else { return nil }
            return UIImage(data: data)
        }
        set {
            imageData = newValue?.pngData()
        }
    }

    // image will be stored as Data
    private var imageData: Data? = nil

    static var `default`: PHPostMemo? {
        get {
            return Defaults[.pkuHolePostMemo]
        }
        set {
            Defaults[.pkuHolePostMemo] = newValue
        }
    }
}
