//
//  PHBackendAPI.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/10.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class PHBackendAPI {

    private let sessionManager: SessionManager

    private init(_ sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    static let shared: PHBackendAPI = {

        var additionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        additionalHeaders["X-PH-Platform"] = "iOS"

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = additionalHeaders
        configuration.timeoutIntervalForRequest = 30.0

        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        let client = PHBackendAPI(sessionManager)

        return client
    }()
}

extension PHBackendAPI {

    static let baseURL = URL(string: "https://pkuhelper.pku.edu.cn/v2/services")!
    static let staticBaseURL = URL(string: "https://pkuhelper.pku.edu.cn/v2/services/static/pkuhole_images")!

    //
    // No secrets here, don't disturb it :)
    //
//    static let baseURL = URL(string: "http://10.128.180.206:23332/_v2/services")!
//    static let staticBaseURL = URL(string: "http://10.128.180.206:23332/_v2/services/static/pkuhole_images")!


    //
    // This method will allow you to handle the raw backend error
    //
    @discardableResult
    static func request<T: BaseMappable>(
        _ router: PHBackendRouter,
        on viewController: UIViewController?,
        errorHandler: @escaping (PHBackendError) -> Void,
        detailHandler: @escaping (T) -> Void)
        -> DataRequest
    {
        PHAPIUtil.showNetworkActivityIndicator(on: viewController)
        return PHBackendAPI.shared.sessionManager
            .request(router)
//            .printCURLRequest() // debug
            .validate(statusCode: 200..<400)
            .validate(contentType: ["application/json"])
            .responsePHV2ObjectMapper { [weak viewController] (response: DataResponse<T>) in
                PHAPIUtil.hideNetworkActivityIndicator(on: viewController)
                switch response.result {
                case let .failure(error):
                    errorHandler(error as! PHBackendError)
                case let .success(detail):
                    detailHandler(detail)
                }
        }
    }

    //
    // This method will automatically parse the errcode field
    //
    @discardableResult
    static func request<T: BaseMappable>(
        _ router: PHBackendRouter,
        on viewController: UIViewController?,
        errorHandler: @escaping (PHBackendError.Errcode, PHBackendError) -> Void,
        detailHandler: @escaping (T) -> Void)
        -> DataRequest
    {
        return PHBackendAPI.request(
            router,
            on: viewController,
            errorHandler: { [weak viewController] backendError in
                switch backendError {
                case let .v2Errcode(code, _, _):
                    guard let errcode  = PHBackendError.Errcode(rawValue: code) else {
                        PHAlert(on: viewController)?.backendError(backendError)
                        return
                    }
                    errorHandler(errcode, backendError)
                default:
                    PHAlert(on: viewController)?.backendError(backendError)
                }
            },
            detailHandler: detailHandler
        )
    }

    //
    // This method will automatically handle all backend error cases
    //
    @discardableResult
    static func request<T: BaseMappable>(
        _ router: PHBackendRouter,
        on viewController: UIViewController?,
        detailHandler: @escaping (T) -> Void)
        -> DataRequest
    {
        return PHBackendAPI.request(
            router,
            on: viewController,
            errorHandler: { [weak viewController] backendError in
                PHAlert(on: viewController)?.backendError(backendError)
            },
            detailHandler: detailHandler
        )
    }

    static func upload<T: BaseMappable>(
        _ router: PHBackendRouter,
        multipartFormData: @escaping (MultipartFormData) -> Void,
        on viewController: UIViewController?,
        errorHandler: @escaping (PHBackendError.Errcode, PHBackendError) -> Void,
        detailHandler: @escaping (T) -> Void)
    {
        PHBackendAPI.shared.sessionManager
            .upload(
                multipartFormData: { (_multipartFormData) in
                    multipartFormData(_multipartFormData)
                    for (key, value) in router.parameters ?? [:] {
                        let data = "\(value)".data(using: String.Encoding.utf8)!
                        _multipartFormData.append(data, withName: key)
                    }
                },
                with: router,
                encodingCompletion: { [weak viewController] result in
                    switch result {
                    case let .success(upload, _, _):
                        PHAPIUtil.showNetworkActivityIndicator(on: viewController)
                        upload
//                            .printCURLRequest() // debug
                            .validate(statusCode: 200..<400)
                            .validate(contentType: ["application/json"])
                            .responsePHV2ObjectMapper { [weak viewController] (response: DataResponse<T>) in
                                PHAPIUtil.hideNetworkActivityIndicator(on: viewController)
                                switch response.result {
                                case let .failure(error):
                                    let backendError = error as! PHBackendError
                                    switch backendError {
                                    case let .v2Errcode(code, _, _):
                                        guard let errcode  = PHBackendError.Errcode(rawValue: code) else {
                                            PHAlert(on: viewController)?.backendError(backendError)
                                            return
                                        }
                                        errorHandler(errcode, backendError)
                                    default:
                                        PHAlert(on: viewController)?.backendError(backendError)
                                    }
                                case let .success(detail):
                                    detailHandler(detail)
                                }
                            }
                    case let .failure(encodingError):
                        PHAlert(on: viewController)?.error(error: encodingError)
                    }
                }
            )
    }
}


protocol PHBackendRouter: URLRequestConvertible {

    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
    var utoken: String? { get }
    func customURLRequest(_ urlRequest: URLRequest) throws -> URLRequest
}

extension PHBackendRouter {

    var parameters: Parameters? { return nil }
    var utoken: String? { return nil }
    func customURLRequest(_ urlRequest: URLRequest) throws -> URLRequest { return urlRequest }

    func asURLRequest() throws -> URLRequest {
        var urlRequest: URLRequest
        urlRequest = try URLRequest(url: PHBackendAPI.baseURL.appendingPathComponent(path), method: method)
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        PHBackendAPI.includeAuthorizaionHeader(&urlRequest, utoken: utoken)
        urlRequest = try customURLRequest(urlRequest)
        return urlRequest
    }
}

extension PHBackendAPI {

    static func includeAuthorizaionHeader(_ urlRequest: inout URLRequest, utoken: String?) {
        if let _utoken = utoken {
            urlRequest.setValue("PH-UTOKEN \(_utoken)", forHTTPHeaderField: "Authorization")
        }
    }
}

extension PHBackendAPI {

    class Image: Equatable, CustomStringConvertible {

        static let filenamePattern: String = "^([0-9a-f]{40})_(\\d+)x(\\d+)\\.(jpeg|jpg|png|bmp|gif|tiff)$"
        static let regexFilename = try! NSRegularExpression(pattern: filenamePattern, options: [.caseInsensitive])

        let groups: [String]


        let filename: String

        let sha1: String

        let format: String

        let width: CGFloat

        var height: CGFloat

        var size: CGSize {
            return CGSize(width: width, height: height)
        }

        var url: URL {
            return Image.getUrl(filename: filename)
        }

        var isValid: Bool {
            return width > 0 && height > 0
        }

        init?(filename: String) {
            guard let groups = filename.extractGroups(for: Image.regexFilename) else { return nil }
            guard groups.count == 1 + 4 else { return nil }
            guard let width = groups[2].cgFloat() else { return nil }
            guard let height = groups[3].cgFloat() else { return nil }
            self.groups = groups
            self.filename = filename
            self.sha1 = groups[1]
            self.format = groups[4]
            self.width = width
            self.height = height
        }

        var description: String {
            return "PHBackendAPI.Image(\(width)x\(height), \(format), \(sha1))"
        }

        static func == (lhs: PHBackendAPI.Image, rhs: PHBackendAPI.Image) -> Bool {
            return lhs.filename == rhs.filename
        }

        static func getUrl(filename: String) -> URL {
            return PHBackendAPI.staticBaseURL.appendingPathComponent(filename)
        }
    }
}

