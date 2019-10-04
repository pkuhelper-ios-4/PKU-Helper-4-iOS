//
//  Alamofire+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/8/10.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire
import ObjectMapper

extension DataRequest {

    static func PHV2ResponseObjectMapperSerializer<T: BaseMappable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in

            // Pass through any underlying URLSession error to the .network case.
            guard error == nil else {
                return .failure(PHBackendError.network(error: error!))
            }

            // Use Alamofire's existing data serializer to extract the data, passing the error as nil, as it has
            // already been handled.
            let result = Request.serializeResponseData(response: response, data: data, error: nil)

            guard case let .success(validData) = result else {
                return .failure(PHBackendError.dataSerialization(error: result.error! as! AFError))
            }

            do {
                let json = try JSONSerialization.jsonObject(with: validData, options: [])
                let v2ResponseStatus = try Mapper<PHV2ResponseStatus>().map(JSONObject: json)

                guard v2ResponseStatus.errcode == 0 else {
                    let code = v2ResponseStatus.errcode, msg = v2ResponseStatus.errmsg, rid = v2ResponseStatus.rid
                    return .failure(PHBackendError.v2Errcode(errcode: code, errmsg: msg, rid: rid))
                }

                let v2ResponseDetail = try Mapper<PHV2ResponseDetail<T>>().map(JSONObject: json)

                return .success(v2ResponseDetail.detail)

            } catch {
                return .failure(PHBackendError.jsonSerialization(error: error))
            }
        }
    }

    @discardableResult
    func responsePHV2ObjectMapper<T: BaseMappable>(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<T>) -> Void)
        -> Self
    {
        return response(
            queue: queue,
            responseSerializer: DataRequest.PHV2ResponseObjectMapperSerializer(),
            completionHandler: completionHandler
        )
    }
}

