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
            let defaultSwimlane = dict["default_swimlane"] as? String,
            let showDefaultSwimlane = dict["show_default_swimlane"] as? String,
            let isActive = dict["is_active"] as? String,
            let isPublic = dict["is_public"] as? String,
            let isPrivate = dict["is_private"] as? String,
            let urls = dict["url"] as? [String:String],
            let lastModified = dict["last_modified"] as? String,
            let lastModifiedInterval = TimeInterval(lastModified)
        else {
            throw InitError()
        }

        self.id = id
        self.name = name
        self.description = dict["description"] as? String
        self.defaultSwimlane = defaultSwimlane
        self.showDefaultSwimlane = showDefaultSwimlane == "1"
        self.isActive = isActive == "1"
        self.isPublic = isPublic == "1"
        self.isPrivate = isPrivate == "1"
        self.boardURLString = urls["board"]
        self.calendarURLString = urls["calendar"]
        self.listURLString = urls["list"]
        self.lastModified = Date(timeIntervalSince1970: lastModifiedInterval)
    }
}
