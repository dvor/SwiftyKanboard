//
//  AbstractRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

protocol AbstractRequest: JSONRPCEncodable {
    /// Parse response from server.
    func parse(_ result: Any) throws

    /// Finish request by notifying user about result.
    func finish()

    /// Block notifying user about request failure
    var failure: (NetworkServiceError) -> Void { get }
}

class BaseRequest {
    let id = RequestIdFactory.next()
    let failure: (NetworkServiceError) -> Void

    init(failure: @escaping (NetworkServiceError) -> Void) {
        self.failure = failure
    }
}
