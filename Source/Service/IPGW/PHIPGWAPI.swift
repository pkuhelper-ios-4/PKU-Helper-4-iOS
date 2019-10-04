//
//  PHIPGWAPI.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class PHIPGWAPI {

    private let sessionManager: SessionManager

    private init(_ sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    static let userAgent: String = {
        let hardware = PHGlobal.device.hardwareString()
        let installUUID = UIDevice.current.identifierForVendor ?? UUID()
        return "IPGWiOS2.0_\(hardware)_\(installUUID.uuidString)"
    }()

    static let shared: PHIPGWAPI = {
        var additionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        additionalHeaders["User-Agent"] = userAgent

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = additionalHeaders
        configuration.timeoutIntervalForRequest = 30.0

        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        let client = PHIPGWAPI(sessionManager)

        return client
    }()
}

extension PHIPGWAPI {

    static let ITSClientURL = URL(string: "https://its.pku.edu.cn/cas/ITSClient")!

    @discardableResult
    static func request<T: PHIPGWBaseResponse>(
        _ router: PHIPGWRouter,
        on viewController: UIViewController?,
        errorHandler: @escaping (PHIPGWError) -> Void,
        successHandler: @escaping (T) -> Void)
        -> DataRequest
    {
        PHAPIUtil.showNetworkActivityIndicator(on: viewController)
        return PHIPGWAPI.shared.sessionManager
            .request(router)
//            .printCURLRequest() // debug
            .validate(statusCode: 200..<400)
            .responsePHIPGWObjectMapper { [weak viewController] (response: DataResponse<T>) in
                PHAPIUtil.hideNetworkActivityIndicator(on: viewController)
                switch response.result {
                case let .failure(error):
                    errorHandler(error as! PHIPGWError)
                case let .success(ipgwResponse):
                    successHandler(ipgwResponse)
                }
            }
    }
}
