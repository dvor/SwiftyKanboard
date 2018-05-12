//
//  GetVersionRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 12/05/2018.
//

import Foundation

class GetVersionRequest: AbstractRequest {
    private let completion: (String) -> Void
    private var response: String?

    required init(completion: @escaping (String) -> Void) {
        self.completion = completion
        super.init(method: "getVersion")
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    override func parse(_ result: Any) -> Bool {
        guard let version = result as? String else {
            return false
        }

        response = version
        return true
    }

    override func finish() {
        completion(response!)
    }
}
