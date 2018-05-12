//
//  RealmExtension.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 12/05/2018.
//

import Foundation
import RealmSwift

extension Realm {
    class func `default`() throws -> Realm {
        let realm = try Realm()
        return realm
    }
}
