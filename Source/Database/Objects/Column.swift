//
//  Column.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation
import RealmSwift

class Column: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var projectId: String = ""
    @objc dynamic var position: Int = 0
    @objc dynamic var taskLimit: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}
