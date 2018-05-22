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
        self.genericSettingsDownloadManager = GenericSettingsDownloadManager(strategy: strategy, downloadQueue: requestsQueue)
        self.projectDownloadManagers = projectIds.map{ ProjectDownloadManager(strategy: strategy, projectId: $0, downloadQueue: requestsQueue) }
        self.projectUploadManagers = projectIds.map{ ProjectUploadManager(strategy: strategy, projectId: $0, uploadQueue: requestsQueue) }
    }

    /// Check whether settings required to run the app were already synced.
    func areRequiredSettingsSynchronized() -> Bool {
        return genericSettingsDownloadManager.areRequiredSettingsSynchronized()
    }

    func synchronizeRequiredSettings(completion: (() -> Void)?, failure: ((NetworkServiceError) -> Void)?) {
        genericSettingsDownloadManager.synchronizeRequiredSettings(completion: completion, failure: failure)
        requestsQueue.start()
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
