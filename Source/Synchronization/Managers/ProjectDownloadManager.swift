//
//  ProjectDownloadManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 22/05/2018.
//

import Foundation

class ProjectDownloadManager {
    private let strategy: SynchronizationStrategy
    private let projectId: String
    private let downloadQueue: DownloadRequestsQueue

    init(strategy: SynchronizationStrategy, projectId: String, downloadQueue: DownloadRequestsQueue) {
        self.strategy = strategy
        self.projectId = projectId
        self.downloadQueue = downloadQueue
    }

    func start() {
        doFullSync()
    }
}

private extension ProjectDownloadManager {
    func doFullSync() {

    }
}
