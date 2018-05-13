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
}

