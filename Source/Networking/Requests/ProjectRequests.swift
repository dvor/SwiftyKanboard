//
//  ProjectRequests.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Foundation

class GetAllProjectsRequest: BaseRequest, AbstractRequest {
    typealias Completion = ([RemoteProject]) -> Void
    private let completion: Completion

    required init(id: Int, completion: @escaping Completion) {
        self.completion = completion
        super.init(id: id, method: "getAllProjects")
    }

    override func process(_ parsedObject: Any) {
        guard let array = parsedObject as? [[String:Any]] else {
            fatalError("oops")
        }

        let response = array.map {
            RemoteProject(dict: $0)
        }
        completion(response)
    }
}
