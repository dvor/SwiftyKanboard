//
//  Project.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Foundation
import RealmSwift

class Project: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var projectDescription: String?

    @objc dynamic var defaultSwimlane: String = ""
    @objc dynamic var showDefaultSwimlane: Bool = false

    @objc dynamic var isActive: Bool = false
    @objc dynamic var isPublic: Bool = false
    @objc dynamic var isPrivate: Bool = false

    @objc dynamic var boardURLString: String?
    @objc dynamic var calendarURLString: String?
    @objc dynamic var listURLString: String?

    @objc dynamic var lastModified: Date = Date()

    override static func primaryKey() -> String? {
        return "id"
    }
}
