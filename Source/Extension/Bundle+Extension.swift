//
//  Bundle+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/5.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Foundation

extension Bundle {

    func url(forFilename: String?) -> URL? {
        guard let filename = forFilename else { return nil }
        let idx = filename.lastIndex(of: ".") ?? filename.endIndex
        let basename = filename[..<idx]
        let ext = filename[filename.index(idx, offsetBy: 1)..<filename.endIndex]
        return Bundle.main.url(forResource: String(basename), withExtension: String(ext))
    }

}


