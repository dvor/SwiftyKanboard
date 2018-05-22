//
//  GetProjectActivityRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

class GetProjectActivityRequest: BaseRequest, DownloadRequest {
    let method = "getProjectActivity"
    let parameters: [String:String]?

    private let completion: ([RemoteProjectActivity]) -> Void
    private var response: [RemoteProjectActivity]?

    required init(projectId: String, completion: @escaping ([RemoteProjectActivity]) -> Void, failure: @escaping (NetworkServiceError) -> Void) {
        self.parameters = [
            "project_id" : projectId
        ]
        self.completion = completion
        super.init(failure: failure)
    }

    func parse(_ result: Any) throws {
        let array = try ArrayDecoder<Any>(result)
        response = try array.map { try RemoteProjectActivity(object: $0) }
    }

    func finish() {
        completion(response!)
    }
}
