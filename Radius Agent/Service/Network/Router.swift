//
//  Router.swift
//  Radius Agent
//
//  Created by Ravi on 29/06/23.
//

import Foundation
import Alamofire

fileprivate let baseUrl = "https://my-json-server.typicode.com/"

enum Router: URLRequestConvertible {
    
    case getFacilitiesAndExclusions
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getFacilitiesAndExclusions:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getFacilitiesAndExclusions:
            return "iranjith4/ad-assignment/db"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: baseUrl + path)!
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        switch self {
        case .getFacilitiesAndExclusions:
            return try URLEncoding.queryString.encode(urlRequest, with: nil)
        }
    }
}
