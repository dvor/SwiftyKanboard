//
//  GetProjectByIdRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

class GetProjectByIdRequest: DownloadRequest {
    let id = RequestIdFactory.next()
    let method = "getProjectById"
    let parameters: [String:String]?

    private let completion: (RemoteProject) -> Void
    private var response: RemoteProject?

    required init(projectId: String, completion: @escaping (RemoteProject) -> Void) {
        self.parameters = [
            "project_id" : projectId
        ]
        self.completion = completion
    }

    func parse(_ result: Any) throws {
        response = try RemoteProject(object: result)
    }

    func finish() {
        completion(response!)
    }
}
