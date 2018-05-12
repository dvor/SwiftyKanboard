//
//  GetAllProjectsRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 12/05/2018.
//

import Foundation

class GetAllProjectsRequest: AbstractRequest {
    private let completion: ([RemoteProject]) -> Void
    private var response: [RemoteProject]?

    required init(completion: @escaping ([RemoteProject]) -> Void) {
        self.completion = completion
        super.init(method: "getAllProjects")
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    override func parse(_ result: Any) -> Bool {
        guard let array = result as? [[String:Any]] else {
            return false
        }

        do {
            response = try array.map { try RemoteProject(dict: $0) }
        }
        catch {
            return false
        }

        return true
    }

    override func finish() {
        completion(response!)
    }
}

extension RemoteProject {
    struct InitError: Error {}

    init(dict: [String:Any]) throws {
        guard
            let id = dict["id"] as? String,
            let name = dict["name"] as? String,
            let lastModified = dict["last_modified"] as? String,
            let lastModifiedInterval = TimeInterval(lastModified)
        else {
            throw InitError()
        }

        self.id = id
        self.name = name
        self.lastModified = Date(timeIntervalSince1970: lastModifiedInterval)
    }
}
