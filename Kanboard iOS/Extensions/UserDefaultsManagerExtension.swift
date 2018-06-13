//
//  UserDefaultsManagerExtension.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/06/2018.
//

import Foundation

extension UserDefaultsManager {
    struct Keys {
        static let activeProjectId = "user-defaults/ative-project-id"
    }

    var activeProjectId: String? {
        get {
            return stringForKey(Keys.activeProjectId)
        }
        set {
            setObject(newValue as AnyObject?, forKey: Keys.activeProjectId)
        }
    }
}
