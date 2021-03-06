//
//  GetAllTasksRequest.swift
//  Kanboard iOS
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

class GetAllTasksRequest: BaseRequest, DownloadRequest {
    let method = "getAllTasks"
    let parameters: [String:String]?

    private let completion: ([RemoteTask]) -> Void
    private var response: [RemoteTask]?

    required init(projectId: String, active: Bool, completion: @escaping ([RemoteTask]) -> Void, failure: @escaping (NetworkServiceError) -> Void) {
        self.parameters = [
            "project_id" : projectId,
            "status_id" : (active ? "1" : "0"),
        ]
        self.completion = completion
        super.init(failure: failure)
    }

    func parse(_ result: Any) throws {
        let array = try ArrayDecoder<Any>(result)
        response = try array.map { try RemoteTask(object: $0) }
    }

    func finish() {
        completion(response!)
    }
}
