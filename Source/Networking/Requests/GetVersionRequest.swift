//
//  GetVersionRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 12/05/2018.
//

import Foundation

class GetVersionRequest: BaseRequest, DownloadRequest {
    let method = "getVersion"
    let parameters: [String:String]? = nil

    private let completion: (String) -> Void
    private var response: String?

    required init(completion: @escaping (String) -> Void, failure: @escaping (NetworkServiceError) -> Void) {
        self.completion = completion
        super.init(failure: failure)
    }

    func parse(_ result: Any) throws {
        response = try ValueDecoder(result).value
    }

    func finish() {
        completion(response!)
    }
}
