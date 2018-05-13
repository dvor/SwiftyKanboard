//
//  GetAllProjectsRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 12/05/2018.
//

import Foundation

class GetAllProjectsRequest: AbstractRequest {
    let id = RequestIdFactory.next()
    let method = "getAllProjects"
    let parameters: [String:String]? = nil

    private let completion: ([RemoteProject]) -> Void
    private var response: [RemoteProject]?

    required init(completion: @escaping ([RemoteProject]) -> Void) {
        self.completion = completion
    }

    func parse(_ result: Any) throws {
        let array = try ArrayDecoder<Any>(result)
        response = try array.map { try RemoteProject(object: $0) }
    }

    func finish() {
        completion(response!)
    }
}

extension RemoteProject {
    init(object: Any) throws {
        let dict = try DictionaryDecoder(object)

        id                  = try dict.value(forKey: "id")
        name                = try dict.value(forKey: "name")
        description         = try dict.optionalValue(forKey: "description")
        defaultSwimlane     = try dict.value(forKey: "default_swimlane")
        showDefaultSwimlane = try dict.boolFromString(forKey: "show_default_swimlane")
        isActive            = try dict.boolFromString(forKey: "is_active")
        isPublic            = try dict.boolFromString(forKey: "is_public")
        isPrivate           = try dict.boolFromString(forKey: "is_private")
        boardURLString      = try dict.nestedDict(forKey: "url").optionalValue(forKey: "board")
        calendarURLString   = try dict.nestedDict(forKey: "url").optionalValue(forKey: "calendar")
        listURLString       = try dict.nestedDict(forKey: "url").optionalValue(forKey: "list")
        lastModified        = try dict.date(forKey: "last_modified")
    }
}
