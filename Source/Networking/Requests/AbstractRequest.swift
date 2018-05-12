//
//  AbstractRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

class AbstractRequest: Encodable {
    let jsonrpc = "2.0"
    let id: RequestId = RequestIdFactory.next()
    let method: String

    private enum CodingKeys: String, CodingKey {
        case jsonrpc
        case id
        case method
    }

    init(method: String) {
        self.method = method
    }

    /// Parse response from server.
    func parse(_ result: Any) -> Bool {
        fatalError("Implement in subclass")
    }

    /// Finish request by notifying user about result.
    func finish() {
        fatalError("Implement in subclass")
    }
}

