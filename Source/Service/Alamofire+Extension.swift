//
//  Alamofire+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire

extension DataRequest {

    func printCURLRequest() -> Self {
        debugPrint(self)
        return self
    }
}
