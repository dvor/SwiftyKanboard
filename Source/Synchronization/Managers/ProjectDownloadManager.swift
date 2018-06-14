//
//  ProjectDownloadManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 22/05/2018.
//

import Foundation
import RealmSwift

class ProjectDownloadManager {
    private let projectId: String
    private let downloadQueue: DownloadRequestsQueue

    init(projectId: String, downloadQueue: DownloadRequestsQueue) {
        self.projectId = projectId
        self.downloadQueue = downloadQueue
    }

    func start() {
        doFullSync()
    }
}

extension ProjectDownloadManager: DownloadManager {
    var areRequiredSettingsSynchronized: Bool {
        get {
            let realm = try! Realm.default()

            let predicate = NSPredicate(format: "id = %@", projectId)
            return realm.objects(Project.self).filter(predicate).count > 0
        }
    }

    func synchronizeRequiredSettings(completion: @escaping (() -> Void), failure: @escaping ((NetworkServiceError) -> Void)) {
        let request = syncProject(completion: completion, failure: failure)
        downloadQueue.add(downloadRequest: request, isConcurent: true)
    }
}

private extension ProjectDownloadManager {
    func doFullSync() {
        downloadQueue.add(downloadRequest: syncProject(), isConcurent: true)
        downloadQueue.add(downloadRequest: syncColumns(), isConcurent: true)
        downloadQueue.add(downloadRequest: syncTasks(active: true), isConcurent: true)
    }

    func syncProject(completion: (() -> Void)? = nil, failure: ((NetworkServiceError) -> Void)? = nil) -> GetProjectByIdRequest {
        return GetProjectByIdRequest(projectId: projectId, completion: { project in
            let realm = try! Realm.default()

            let updater: DatabaseUpdater<RemoteProject, Project> = DatabaseUpdater(realm: realm)
            updater.updateDatabase(with: [project])

            completion?()
        },
        failure: { error in
            failure?(error)
        })
    }

    func syncColumns() -> GetColumnsRequest {
        return GetColumnsRequest(projectId: projectId, completion: { columns in
            let realm = try! Realm.default()

            let updater: DatabaseUpdater<RemoteColumn, Column> = DatabaseUpdater(realm: realm)
            updater.updateDatabase(with: columns)
        },
        failure: { _ in })
    }

    func syncTasks(active: Bool) -> GetAllTasksRequest {
        return GetAllTasksRequest(projectId: projectId, active: active, completion: { tasks in
            let realm = try! Realm.default()

            let updater: DatabaseUpdater<RemoteTask, Task> = DatabaseUpdater(realm: realm)
            updater.updateDatabase(with: tasks)
        },
        failure: { _ in })
    }
}
