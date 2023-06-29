//
//  NetworkManager.swift
//  Radius Agent
//
//  Created by Ravi on 29/06/23.
//

import Foundation
import Alamofire

struct NetworkManager {
    static func makeRequest<T: Decodable>(urlRequest: URLRequestConvertible, model: T.Type) async -> Result<T, AFError> {
        return await AF.request(urlRequest).serializingDecodable(model).result
    }
}
