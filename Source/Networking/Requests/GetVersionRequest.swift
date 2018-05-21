//
//  GetVersionRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 12/05/2018.
//

import Foundation

class GetVersionRequest: DownloadRequest {
    let id = RequestIdFactory.next()
    let method = "getVersion"
    let parameters: [String:String]? = nil

    private let completion: (String) -> Void
    private var response: String?

    required init(completion: @escaping (String) -> Void) {
        self.completion = completion
    }

    func parse(_ result: Any) throws {
        response = try ValueDecoder(result).value
    }

    func finish() {
        completion(response!)
    }
}
