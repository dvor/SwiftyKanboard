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
        let request = GetProjectByIdRequest(projectId: projectId, completion: { project in
            let realm = try! Realm.default()

            let updater: DatabaseUpdater<RemoteProject, Project> = DatabaseUpdater(realm: realm)
            _ = updater.updateDatabase(with: project)

            completion()
        },
        failure: failure)

        downloadQueue.add(downloadRequest: request, isConcurent: true)
    }
}

private extension ProjectDownloadManager {
    func doFullSync() {

    }
}
