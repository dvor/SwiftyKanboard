//
//  AbstractRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

protocol AbstractRequest: Encodable {
    associatedtype Completion
    init(id: Int, completion: Completion)
}

class BaseRequest: Encodable {
    let jsonrpc = "2.0"
    let id: Int
    let method: String

    init(id: Int, method: String) {
        self.id = id
        self.method = method
    }

    func process(_ parsedObject: Any) {
        fatalError("Implement in subclass")
    }
}

