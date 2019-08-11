//
//  ProjectLocalInfo.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 24/06/2018.
//

import Realm
import RealmSwift

class ProjectLocalInfo: Object {
    @objc dynamic var lastActiveColumn: Int = 0
    @objc dynamic var lastSyncDate: Date = Date()
}
