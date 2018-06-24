//
//  Project.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import RealmSwift

class Project: Object {
    // Remove properties
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

    // Local info isn't synced from/to the server.
    @objc dynamic var localInfo: ProjectLocalInfo?

    // This function should be run inside realm write block.
    func createLocalInfoIfNeeded() -> ProjectLocalInfo {
        if let localInfo = self.localInfo {
            return localInfo
        }

        let localInfo = ProjectLocalInfo()
        self.localInfo = localInfo
        return localInfo
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
