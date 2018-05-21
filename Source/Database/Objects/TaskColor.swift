//
//  TaskColor.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import Foundation
import RealmSwift

class TaskColor: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""

    @objc dynamic var backgroundRed: Double = 0
    @objc dynamic var backgroundGreen: Double = 0
    @objc dynamic var backgroundBlue: Double = 0

    @objc dynamic var borderRed: Double = 0
    @objc dynamic var borderGreen: Double = 0
    @objc dynamic var borderBlue: Double = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}
