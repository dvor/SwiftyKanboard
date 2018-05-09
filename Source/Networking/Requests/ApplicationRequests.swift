//
//  ApplicationRequests.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Foundation

class GetVersionRequest: BaseRequest, AbstractRequest {
    typealias Completion = (String) -> Void
    private let completion: Completion

    required init(id: Int, completion: @escaping Completion) {
        self.completion = completion
        super.init(id: id, method: "getVersion")
    }

    override func process(_ parsedObject: Any) {
        let response = parsedObject as! String
        completion(response)
    }
}
