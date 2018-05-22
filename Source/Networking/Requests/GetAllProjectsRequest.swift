//
//  GetAllProjectsRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 12/05/2018.
//

import Foundation

class GetAllProjectsRequest: BaseRequest, DownloadRequest {
    let method = "getAllProjects"
    let parameters: [String:String]? = nil

    private let completion: ([RemoteProject]) -> Void
    private var response: [RemoteProject]?

    required init(completion: @escaping ([RemoteProject]) -> Void, failure: @escaping (NetworkServiceError) -> Void) {
        self.completion = completion
        super.init(failure: failure)
    }

    func parse(_ result: Any) throws {
        let array = try ArrayDecoder<Any>(result)
        response = try array.map { try RemoteProject(object: $0) }
    }

    func finish() {
        completion(response!)
    }
}
