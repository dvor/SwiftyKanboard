//
//  ProjectSynchronizer.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 11/05/2018.
//

import Foundation
import RealmSwift

class ProjectSynchronizer: Synchronizer {
    private let realm: Realm

    init(realm: Realm) {
        self.realm = realm
    }

    func updateDatabase(with remote: RemoteProject) -> SynchronizerResult {
        let predicate = NSPredicate(format: "id = %@", remote.id)
        let projects = realm.objects(Project.self).filter(predicate)

        if projects.count > 1 {
            log("Inconsistent database: found several projects with same id \(projects)")
            return .internalError
        }

        do {
            if let project = projects.first {
                return try updateIfNeeded(project, with: remote) ? .updated : .unchanged
            }
            else {
                try createProject(from: remote)
                return .created
            }
        }
        catch let error as NSError {
            log("Cannot write to realm: \(error)")
            return .internalError
        }
    }
}

private extension ProjectSynchronizer {
    func createProject(from remote: RemoteProject) throws {
        let project = Project()
        project.update(with: remote)

        log("Creating new project: \(project)")

        try realm.write {
            realm.add(project)
        }
    }

    func updateIfNeeded(_ project: Project, with remote: RemoteProject) throws -> Bool {
        log("Syncing project \(remote.id)")

        if project.equal(to: remote) {
            log("Nothing to update")
            return false
        }

        try realm.write {
            project.update(with: remote)
        }

        log("Updated project: \(project)")

        return true
    }
}

extension Project {
    func equal(to remote: RemoteProject) -> Bool {
        return
            id == remote.id &&
            name == remote.name &&
            projectDescription == remote.description &&
            defaultSwimlane == remote.defaultSwimlane &&
            showDefaultSwimlane == remote.showDefaultSwimlane &&
            isActive == remote.isActive &&
            isPublic == remote.isPublic &&
            isPrivate == remote.isPrivate &&
            boardURLString == remote.boardURLString &&
            calendarURLString == remote.calendarURLString &&
            listURLString == remote.listURLString &&
            lastModified == remote.lastModified
    }

    func update(with remote: RemoteProject) {
        id = remote.id
        name = remote.name
        projectDescription = remote.description
        defaultSwimlane = remote.defaultSwimlane
        showDefaultSwimlane = remote.showDefaultSwimlane
        isActive = remote.isActive
        isPublic = remote.isPublic
        isPrivate = remote.isPrivate
        boardURLString = remote.boardURLString
        calendarURLString = remote.calendarURLString
        listURLString = remote.listURLString
        lastModified = remote.lastModified
    }
}
