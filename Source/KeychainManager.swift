//
//  KeychainManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Foundation

class KeychainManager {
    private struct Constants {
        static let activeAccountDataService = "me.dvor.Kanboard.KeychainManager.activeAccountDataService"
        static let baseURL = "baseURL"
        static let userName = "userName"
        static let apiToken = "apiToken"
    }

    var baseURL: String? {
        get {
            return getStringForKey(Constants.baseURL)
        }
        set {
            setString(newValue, forKey: Constants.baseURL)
        }
    }

    // User name for logged in user.
    var userName: String? {
        get {
            return getStringForKey(Constants.userName)
        }
        set {
            setString(newValue, forKey: Constants.userName)
        }
    }

    // API token for logged in user.
    var apiToken: String? {
        get {
            return getStringForKey(Constants.apiToken)
        }
        set {
            setString(newValue, forKey: Constants.apiToken)
        }
    }

    var isLoggedIn: Bool {
        get {
            return baseURL != nil && userName != nil && apiToken != nil
        }
    }

    /// Removes all data related to active account.
    func deleteActiveAccountData() {
        baseURL = nil
        userName = nil
        apiToken = nil
    }
}

private extension KeychainManager {
    func getIntForKey(_ key: String) -> Int? {
        guard let data = getDataForKey(key) else {
            return nil
        }

        guard let number = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSNumber else {
            return nil
        }

        return number.intValue
    }

    func setInt(_ value: Int?, forKey key: String) {
        guard let value = value else {
            setData(nil, forKey: key)
            return
        }

        let number = NSNumber(value: value)

        let data = NSKeyedArchiver.archivedData(withRootObject: number)
        setData(data, forKey: key)
    }

    func getStringForKey(_ key: String) -> String? {
        guard let data = getDataForKey(key) else {
            return nil
        }

        return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
    }

    func setString(_ string: String?, forKey key: String) {
        let data = string?.data(using: String.Encoding.utf8)
        setData(data, forKey: key)
    }

    func getBoolForKey(_ key: String) -> Bool? {
        guard let data = getDataForKey(key) else {
            return nil
        }

        return (data as NSData).bytes.bindMemory(to: Int.self, capacity: data.count).pointee == 1
    }

    func setBool(_ value: Bool?, forKey key: String) {
        var data: Data? = nil

        if let value = value {
            var bytes = value ? 1 : 0
            withUnsafePointer(to: &bytes) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    data = Data(bytes: $0, count: MemoryLayout<Int>.size)
                }
            }
        }

        setData(data, forKey: key)
    }

    func getDataForKey(_ key: String) -> Data? {
        var query = genericQueryWithKey(key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        if status == errSecItemNotFound {
            return nil
        }

        guard status == noErr else {
            log("Error when getting keychain data for key \(key), status \(status)")
            return nil
        }

        guard let data = queryResult as? Data else {
            log("Unexpected data for key \(key)")
            return nil
        }

        return data
    }

    func setData(_ newData: Data?, forKey key: String) {
        let oldData = getDataForKey(key)

        switch (oldData, newData) {
            case (.some(_), .some(let data)):
                // Update
                let query = genericQueryWithKey(key)

                var attributesToUpdate = [String : AnyObject]()
                attributesToUpdate[kSecValueData as String] = data as AnyObject?

                let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
                guard status == noErr else {
                    log("Error when updating keychain data for key \(key), status \(status)")
                    return
                }

            case (.some(_), .none):
                // Delete
                let query = genericQueryWithKey(key)
                let status = SecItemDelete(query as CFDictionary)
                guard status == noErr else {
                    log("Error when updating keychain data for key \(key), status \(status)")
                    return
                }

            case (.none, .some(let data)):
                // Add
                var query = genericQueryWithKey(key)
                query[kSecValueData as String] = data as AnyObject?

                let status = SecItemAdd(query as CFDictionary, nil)
                guard status == noErr else {
                    log("Error when setting keychain data for key \(key), status \(status)")
                    return
                }

            case (.none, .none):
                // Nothing to do here, no changes
                break
        }
    }

    func genericQueryWithKey(_ key: String) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = Constants.activeAccountDataService as AnyObject?
        query[kSecAttrAccount as String] = key as AnyObject?
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        return query
    }
}
