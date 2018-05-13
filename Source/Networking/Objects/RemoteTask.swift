//
//  RemoteTask.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

struct RemoteTask: RemoteObject {
    let id: String
    let title: String
    let description: String?
    let urlString: String

    let isActive: Bool
    let position: Int
    let score: Int
    let priority: Int

    let colorId: String
    let projectId: String
    let columnId: String
    let ownerId: String
    let creatorId: String
    let categoryId: String
    let swimlaneId: String

    let creationDate: Date
    let startedDate: Date?
    let dueDate: Date?
    let modificationDate: Date
    let movedDate: Date
    let completedDate: Date?

    init(object: Any) throws {
        let dict = try DictionaryDecoder(object)

        id = try dict.value(forKey: "id")
        title = try dict.value(forKey: "title")
        description = try dict.optionalValue(forKey: "description")
        urlString = try dict.value(forKey: "url")

        isActive = try dict.boolFromString(forKey: "is_active")
        position = try dict.intFromString(forKey: "position")
        score = try dict.intFromString(forKey: "score")
        priority = try dict.intFromString(forKey: "priority")

        colorId = try dict.value(forKey: "color_id")
        projectId = try dict.value(forKey: "project_id")
        columnId = try dict.value(forKey: "column_id")
        ownerId = try dict.value(forKey: "owner_id")
        creatorId = try dict.value(forKey: "creator_id")
        categoryId = try dict.value(forKey: "category_id")
        swimlaneId = try dict.value(forKey: "swimlane_id")

        creationDate = try dict.date(forKey: "date_creation")
        startedDate = try dict.optionalDate(forKey: "date_started")
        dueDate = try dict.optionalDate(forKey: "date_due")
        modificationDate = try dict.date(forKey: "date_modification")
        movedDate = try dict.date(forKey: "date_moved")
        completedDate = try dict.optionalDate(forKey: "date_completed")
    }
}
