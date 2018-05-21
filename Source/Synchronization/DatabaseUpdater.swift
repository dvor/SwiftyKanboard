//
//  DatabaseUpdater.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 11/05/2018.
//

import Foundation
import RealmSwift

protocol Updatable {
    var id: String { get set }
    func isEqual(to remote: RemoteObject) -> Bool
    func update(with remote: RemoteObject)
}

enum DatabaseUpdaterResult {
    case internalError
    case unchanged
    case created
    case updated
}

class DatabaseUpdater<RemoteType: RemoteObject, LocalType: Object & Updatable> {
    private let realm: Realm

    init(realm: Realm) {
        self.realm = realm
    }

    func updateDatabase(with remote: RemoteType) -> DatabaseUpdaterResult {
        let predicate = NSPredicate(format: "id = %@", remote.id)
        let locals = realm.objects(LocalType.self).filter(predicate)

        if locals.count > 1 {
            log("Inconsistent database: found several objects with same id \(locals)")
            return .internalError
        }

        do {
            if let local = locals.first {
                return try updateIfNeeded(local, with: remote) ? .updated : .unchanged
            }
            else {
                try createLocal(from: remote)
                return .created
            }
        }
        catch let error as NSError {
            log("Cannot write to realm: \(error)")
            return .internalError
        }
    }
}

private extension DatabaseUpdater {
    func createLocal(from remote: RemoteType) throws {
        var local = LocalType()
        local.id = remote.id
        local.update(with: remote)

        log("Creating new object: \(local)")

        try realm.write {
            realm.add(local)
        }
    }

    func updateIfNeeded(_ local: LocalType, with remote: RemoteType) throws -> Bool {
        log("Syncing object \(LocalType.self) with id \(remote.id)")

        if local.isEqual(to: remote) {
            log("Nothing to update")
            return false
        }

        try realm.write {
            local.update(with: remote)
        }

        log("Updated object: \(local)")

        return true
    }
}
