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
    @objc dynamic var name: String?
}
