//
//  RemoteProject.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

struct RemoteProject: RemoteObject {
    let id: String
    let name: String
    let description: String?

    let defaultSwimlane: String
    let showDefaultSwimlane: Bool

    let isActive: Bool
    let isPublic: Bool
    let isPrivate: Bool

    let boardURLString: String?
    let calendarURLString: String?
    let listURLString: String?

    let lastModified: Date

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
