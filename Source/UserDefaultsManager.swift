//
//  UserDefaultsManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/06/2018.
//

import Foundation

class UserDefaultsManager {
    func setObject(_ object: AnyObject?, forKey key: String) {
        let defaults = UserDefaults.standard
        defaults.set(object, forKey:key)
        defaults.synchronize()
    }

    func stringForKey(_ key: String) -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: key)
    }

    func setBool(_ value: Bool, forKey key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    func boolForKey(_ key: String, defaultValue: Bool) -> Bool {
        let defaults = UserDefaults.standard

        if let result = defaults.object(forKey: key) {
            return (result as AnyObject).boolValue
        }
        else {
            return defaultValue
        }
    }

    func removeObjectForKey(_ key: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
}
