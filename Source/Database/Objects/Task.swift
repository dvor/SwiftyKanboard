//
//  Task.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var taskDescription: String? = nil
    @objc dynamic var urlString: String = ""

    @objc dynamic var isActive: Bool = false
    @objc dynamic var position: Int = 0
    @objc dynamic var score: Int = 0
    @objc dynamic var priority: Int = 0

    @objc dynamic var colorId: String = ""
    @objc dynamic var projectId: String = ""
    @objc dynamic var columnId: String = ""
    @objc dynamic var ownerId: String = ""
    @objc dynamic var creatorId: String = ""
    @objc dynamic var categoryId: String = ""
    @objc dynamic var swimlaneId: String = ""

    @objc dynamic var creationDate: Date = Date()
    @objc dynamic var startedDate: Date? = nil
    @objc dynamic var dueDate: Date? = nil
    @objc dynamic var modificationDate: Date = Date()
    @objc dynamic var movedDate: Date = Date()
    @objc dynamic var completedDate: Date? = nil

    override static func primaryKey() -> String? {
        return "id"
    }
}
