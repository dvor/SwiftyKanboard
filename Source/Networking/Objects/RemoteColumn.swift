//
//  RemoteColumn.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

struct RemoteColumn: RemoteObject {
    let id: String
    let title: String
    let projectId: String
    let position: Int
    let taskLimit: Int

    init(object: Any) throws {
        let dict = try DictionaryDecoder(object)

        id        = try dict.value(forKey: "id")
        title     = try dict.value(forKey: "title")
        projectId = try dict.value(forKey: "project_id")
        position  = try dict.intFromString(forKey: "position")
        taskLimit = try dict.intFromString(forKey: "task_limit")
    }
}
