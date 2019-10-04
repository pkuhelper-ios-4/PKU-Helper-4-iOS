//
//  PHIPGWAPI+Alamofire+Extension.swift
//  PKUHelper-4
//
//  Created by zxh on 2019/9/1.
//  Copyright © 2019 PKUHelper. All rights reserved.
//

import Alamofire
import ObjectMapper

extension DataRequest {

    static func PHIPGWResponseObjectMapperSerializer<T: PHIPGWBaseResponse>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in

            // Pass through any underlying URLSession error to the .network case.
            guard error == nil else {
                return .failure(PHIPGWError.network(error: error!))
            }

            // Use Alamofire's existing data serializer to extract the data, passing the error as nil, as it has
            // already been handled.
            let result = Request.serializeResponseData(response: response, data: data, error: nil)

            guard case let .success(validData) = result else {
                return .failure(PHIPGWError.dataSerialization(error: result.error! as! AFError))
            }

            var json: Any

            do {
                json = try JSONSerialization.jsonObject(with: validData, options: [])
            } catch {
                return .failure(PHIPGWError.jsonSerialization(error: error))
            }

            do {
                let ipgwResponse = try Mapper<T>().map(JSONObject: json)
                return .success(ipgwResponse)
            } catch {
                do {
                    let ipgwErrorResponse = try Mapper<PHIPGWErrorResponse>().map(JSONObject: json)
                    return .failure(PHIPGWError.ipgwError(message: ipgwErrorResponse.error))
                } catch {

                }
                return .failure(PHIPGWError.jsonSerialization(error: error))
            }
        }
    }

    @discardableResult
    func responsePHIPGWObjectMapper<T: PHIPGWBaseResponse>(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<T>) -> Void)
        -> Self
    {
        return response(
            queue: queue,
            responseSerializer: DataRequest.PHIPGWResponseObjectMapperSerializer(),
            completionHandler: completionHandler
        )
    }
}

