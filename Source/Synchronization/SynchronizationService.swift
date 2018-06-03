//
//  SynchronizationService.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import Foundation
import RealmSwift

class SynchronizationService {
    private let projectIds: [String]
    private let serviceQueue: DispatchQueue
    private let requestsQueue: RequestsQueue

    private let genericSettingsDownloadManager: GenericSettingsDownloadManager
    private let projectDownloadManagers: [ProjectDownloadManager]
    private let projectUploadManagers: [ProjectUploadManager]

    private var isRunning = false

    init(projectIds: [String],
         strategy: SynchronizationStrategy,
         baseURL: URL,
         userName: String,
         apiToken: String) throws {

        // Create realm to handle possible errors early (migration, misconfiguration, etc).
        _ = try Realm.default()

        let serviceQueue = DispatchQueue(label: "SynchronizationService queue", autoreleaseFrequency: .workItem)

        self.projectIds = projectIds
        self.serviceQueue = serviceQueue

        let networkService = NetworkService(baseURL: baseURL, userName: userName, apiToken: apiToken, delegateQueue: serviceQueue)
        let requestsQueue = RequestsQueue(networkService: networkService, strategy: strategy, queue: serviceQueue)

        self.requestsQueue = requestsQueue
        self.genericSettingsDownloadManager = GenericSettingsDownloadManager(downloadQueue: requestsQueue)
        self.projectDownloadManagers = projectIds.map{ ProjectDownloadManager(projectId: $0, downloadQueue: requestsQueue) }
        self.projectUploadManagers = projectIds.map{ ProjectUploadManager(projectId: $0, uploadQueue: requestsQueue) }
    }

    /// Check whether settings required to run the app were already synced.
    var areRequiredSettingsSynchronized: Bool {
        get {
            return genericSettingsDownloadManager.areRequiredSettingsSynchronized &&
                   projectDownloadManagers.reduce(true, { $0 && $1.isProjectDownloaded })
        }
    }

    func synchronizeRequiredSettings(resultQueue: DispatchQueue,
                                     completion: (() -> Void)?,
                                     failure: ((NetworkServiceError) -> Void)?) {
        serviceQueue.async { [weak self] in
            guard let `self` = self else { return }

            let generic = self.genericSettingsDownloadManager
            let managers = self.projectDownloadManagers.filter{ !$0.isProjectDownloaded }

            var blocksNumber = managers.count
            if !generic.areRequiredSettingsSynchronized {
                blocksNumber += 1
            }

            let barrier = CallbackBarrier<NetworkServiceError>(blocksNumber: blocksNumber,
                                                               resultQueue: resultQueue,
                                                               completion: completion,
                                                               failure: failure)

            if !generic.areRequiredSettingsSynchronized {
                generic.synchronizeRequiredSettings(completion: barrier.completion, failure: barrier.failure)
            }

            managers.forEach {
                $0.downloadProjects(completion: barrier.completion, failure: barrier.failure)
            }

            self.requestsQueue.start()
        }
    }

    /// Start synchronization of projects and their components.
    func startSynchronization() {
        serviceQueue.async { [weak self] in
            guard let `self` = self else { return }

            if self.isRunning { return }
            self.isRunning = true

            self.genericSettingsDownloadManager.start()
            self.projectDownloadManagers.forEach{ $0.start() }
            self.projectUploadManagers.forEach{ $0.start() }
            self.requestsQueue.start()
        }
    }
}

private extension SynchronizationService {
}
