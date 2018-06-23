//
//  MoveTaskPositionRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/06/2018.
//

import Foundation

class MoveTaskPositionRequest: BaseRequest, UploadRequest {
    let method = "moveTaskPosition"
    let parameters: [String:String]?

    private let completion: (Bool) -> Void
    private var response: Bool?

    required init(projectId: String,
                  taskId: String,
                  columnId: String,
                  position: Int,
                  swimlaneId: String,
                  completion: @escaping (Bool) -> Void,
                  failure: @escaping (NetworkServiceError) -> Void) {
        self.parameters = [
            "project_id" : projectId,
            "task_id": taskId,
            "column_id": columnId,
            "position": String(position),
            "swimlane_id": swimlaneId,
        ]
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
