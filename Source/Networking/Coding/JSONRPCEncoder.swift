//
//  JSONRPCEncoder.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

protocol JSONRPCEncodable {
    var id: RequestId { get }
    var method: String { get }
    var parameters: [String:String]? { get }
}

class JSONRPCEncoder {
    static func encodeRPCRequests(_ objects: [JSONRPCEncodable]) throws -> Data {
        let array: [[String:Any]] = objects.map { object in
            var dict = [String:Any]()

            dict["jsonrpc"] = "2.0"
            dict["id"] = object.id
            dict["method"] = object.method
            if let parameters = object.parameters {
                dict["params"] = parameters
            }

            return dict
        }

        return try JSONSerialization.data(withJSONObject: array, options: [])
    }
}
