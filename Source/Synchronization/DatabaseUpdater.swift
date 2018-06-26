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

class DatabaseUpdater<RemoteType: RemoteObject, LocalType: Object & Updatable> {
    private let realm: Realm

    init(realm: Realm) {
        self.realm = realm
    }

    func updateDatabase(with remotes: [RemoteType]) {
        realm.beginWrite()

        remotes.forEach {
            updateDatabase(with: $0)
        }

        realmSafeCommitWrite()
    }

    func removeObjects(notFoundIn remotes: [RemoteType], filteredWithPredicate predicate: NSPredicate? = nil) {
        let ids = Set(remotes.map{ $0.id })
        var allPredicates = [NSPredicate(format: "NOT (id IN %@)", ids)]

        if let predicate = predicate {
            allPredicates.append(predicate)
        }

        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
        log.infoMessage("Removing objects matching predicate: \(compound)")

        let toDelete = realm.objects(LocalType.self).filter(compound)
        log.infoMessage("Removing objects: \(toDelete)")

        realm.beginWrite()
        realm.delete(toDelete)
        realmSafeCommitWrite()
    }
}

private extension DatabaseUpdater {
    func realmSafeCommitWrite() {
        do {
            try realm.commitWrite()
        }
        catch let error as NSError {
            log.errorMessage("Cannot write to realm: \(error)")
        }
    }

    func updateDatabase(with remote: RemoteType) {
        let predicate = NSPredicate(format: "id = %@", remote.id)
        let locals = realm.objects(LocalType.self).filter(predicate)

        if locals.count > 1 {
            log.errorMessage("Inconsistent database: found several objects with same id \(locals)")
        }

        if let local = locals.first {
            _ = updateIfNeeded(local, with: remote)
        }
        else {
            createLocal(from: remote)
        }
    }

    func createLocal(from remote: RemoteType) {
        var local = LocalType()
        local.id = remote.id
        local.update(with: remote)

        log.infoMessage("Creating new object: \(local)")

        realm.add(local)
    }

    func updateIfNeeded(_ local: LocalType, with remote: RemoteType) -> Bool {
        log.infoMessage("Syncing object \(LocalType.self) with id \(remote.id)")

        if local.isEqual(to: remote) {
            log.infoMessage("Nothing to update")
            return false
        }

        local.update(with: remote)
        log.infoMessage("Updated object: \(local)")

        return true
    }
}
