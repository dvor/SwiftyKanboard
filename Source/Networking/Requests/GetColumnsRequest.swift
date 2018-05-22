//
//  GetColumnsRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

class GetColumnsRequest: BaseRequest, DownloadRequest {
    let method = "getColumns"
    let parameters: [String:String]?

    private let completion: ([RemoteColumn]) -> Void
    private var response: [RemoteColumn]?

    required init(projectId: String, completion: @escaping ([RemoteColumn]) -> Void, failure: @escaping (NetworkServiceError) -> Void) {
        self.parameters = [
            "project_id" : projectId
        ]
        self.completion = completion
        super.init(failure: failure)
    }

    func parse(_ result: Any) throws {
        let array = try ArrayDecoder<Any>(result)
        response = try array.map { try RemoteColumn(object: $0) }
    }

    func finish() {
        completion(response!)
    }
}
