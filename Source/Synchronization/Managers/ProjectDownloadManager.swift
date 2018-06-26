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
    private let strategy: SynchronizationStrategy
    private let dispatchQueue: DispatchQueue
    private let downloadQueue: DownloadRequestsQueue

    private var runningSmartSync = false
    private var scheduledSmartSyncIteration = 0

    init(projectId: String,
         strategy: SynchronizationStrategy,
         dispatchQueue: DispatchQueue,
         downloadQueue: DownloadRequestsQueue) {

        self.projectId = projectId
        self.strategy = strategy
        self.dispatchQueue = dispatchQueue
        self.downloadQueue = downloadQueue
    }

    func start() {
        doSmartSync()
    }

    func synchronizeNow() {
        doSmartSync()
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
    func scheduleNextSmartSync() {
        runningSmartSync = false

        scheduledSmartSyncIteration += 1
        let iteration = scheduledSmartSyncIteration
        let deadline = DispatchTime.now() + strategy.downloadSyncDelay

            log.infoMessage("scheduleNextSmartSync... scheduling for \(deadline)")

        dispatchQueue.asyncAfter(deadline: deadline) { [weak self] in
            log.infoMessage("scheduleNextSmartSync... starting scheduled sync")

            guard let `self` = self else { return }
            guard self.scheduledSmartSyncIteration == iteration else {
                log.infoMessage("scheduleNextSmartSync... another sync running, quit")
                return
            }

            self.doSmartSync()
        }
    }

    func doSmartSync() {
        log.infoMessage("doSmartSync...")

        if runningSmartSync {
            log.infoMessage("doSmartSync... already running, quit")
            return
        }
        runningSmartSync = true

        log.infoMessage("doSmartSync... syncing project...")

        let request = syncProject(completion: { [weak self] in
            guard let `self` = self else { return }

            if self.isProjectFullySynced() {
                log.infoMessage("doSmartSync... no new updates, quit")
                self.scheduleNextSmartSync()
                return
            }
            let projectLastModified = self.getProject()!.lastModified

            self.syncTasksAndColumns(projectLastModified)
        }, failure: { [weak self] error in
            // TODO handle error
            log.infoMessage("doSmartSync... failed with error \(error)")
            self?.scheduleNextSmartSync()
        })

        downloadQueue.add(downloadRequest: request, isConcurent: true)
    }

    func syncTasksAndColumns(_ projectLastModified: Date) {
        log.infoMessage("doSmartSync... syncing tasks and columns...")

        let barrier = CallbackBarrier<NetworkServiceError>(blocksNumber: 2,
                                                           resultQueue: self.dispatchQueue,
                                                           completion: { [weak self] in
            guard let `self` = self else { return }

            log.infoMessage("doSmartSync... successfully synced")
            self.updateProjectLastModified(projectLastModified)
            self.scheduleNextSmartSync()
        }, failure: { [weak self] error in
            // TODO handle error
            log.infoMessage("doSmartSync... failed with error \(error)")
            self?.scheduleNextSmartSync()
        })

        let tasks = syncTasks(active: true, completion: barrier.completion, failure: barrier.failure)
        let columns = syncColumns(completion: barrier.completion, failure: barrier.failure)

        downloadQueue.add(downloadRequest: tasks, isConcurent: true)
        downloadQueue.add(downloadRequest: columns, isConcurent: true)
    }

    func getProject() -> Project? {
        let realm = try! Realm.default()
        return realm.objects(Project.self).filter(NSPredicate(format: "id == %@", projectId)).first
    }

    func isProjectFullySynced() -> Bool {
        guard let project = getProject(), let lastSyncDate = project.localInfo?.lastSyncDate else {
            return false
        }

        return project.lastModified == lastSyncDate
    }

    func updateProjectLastModified(_ projectLastModified: Date) {
        guard let project = getProject() else {
            return
        }

        let realm = try! Realm.default()
        try? realm.write {
            project.createLocalInfoIfNeeded().lastSyncDate = projectLastModified
        }
    }

    func syncProject(completion: @escaping (() -> Void), failure: @escaping ((NetworkServiceError) -> Void)) -> GetProjectByIdRequest {
        return GetProjectByIdRequest(projectId: projectId, completion: { project in
            let realm = try! Realm.default()

            let updater: DatabaseUpdater<RemoteProject, Project> = DatabaseUpdater(realm: realm)
            updater.updateDatabase(with: [project])

            completion()
        },
        failure: failure)
    }

    func syncColumns(completion: @escaping (() -> Void), failure: @escaping ((NetworkServiceError) -> Void)) -> GetColumnsRequest {
        let projectId = self.projectId

        return GetColumnsRequest(projectId: projectId, completion: { columns in
            let realm = try! Realm.default()

            let updater: DatabaseUpdater<RemoteColumn, Column> = DatabaseUpdater(realm: realm)
            updater.updateDatabase(with: columns)
            updater.removeObjects(notFoundIn: columns,
                                  filteredWithPredicate: NSPredicate(format: "projectId == %@", projectId))

            completion()
        },
        failure: failure)
    }

    func syncTasks(active: Bool, completion: @escaping (() -> Void), failure: @escaping ((NetworkServiceError) -> Void)) -> GetAllTasksRequest {
        let projectId = self.projectId

        return GetAllTasksRequest(projectId: projectId, active: active, completion: { tasks in
            let realm = try! Realm.default()

            let updater: DatabaseUpdater<RemoteTask, Task> = DatabaseUpdater(realm: realm)
            updater.updateDatabase(with: tasks)
            updater.removeObjects(notFoundIn: tasks,
                                  filteredWithPredicate: NSPredicate(format: "projectId == %@", projectId))

            completion()
        },
        failure: failure)
    }
}
