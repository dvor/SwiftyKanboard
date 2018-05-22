//
//  GetProjectByIdRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

class GetProjectByIdRequest: BaseRequest, DownloadRequest {
    let method = "getProjectById"
    let parameters: [String:String]?

    private let completion: (RemoteProject) -> Void
    private var response: RemoteProject?

    required init(projectId: String, completion: @escaping (RemoteProject) -> Void, failure: @escaping (NetworkServiceError) -> Void) {
        self.parameters = [
            "project_id" : projectId
        ]
        self.completion = completion
        super.init(failure: failure)
    }

    func parse(_ result: Any) throws {
        response = try RemoteProject(object: result)
    }

    func finish() {
        completion(response!)
    }
}
