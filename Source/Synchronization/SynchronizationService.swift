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
            let managers: [DownloadManager] = [genericSettingsDownloadManager] + projectDownloadManagers

            return managers.reduce(true, { $0 && $1.areRequiredSettingsSynchronized })
        }
    }

    func synchronizeRequiredSettings(resultQueue: DispatchQueue,
                                     completion: (() -> Void)?,
                                     failure: ((NetworkServiceError) -> Void)?) {
        serviceQueue.async { [weak self] in
            guard let `self` = self else { return }

            var managers: [DownloadManager] = [self.genericSettingsDownloadManager] + self.projectDownloadManagers
            managers = managers.filter {
                !$0.areRequiredSettingsSynchronized
            }

            guard managers.count > 0 else {
                resultQueue.async{
                    completion?()
                }
                return
            }

            let barrier = CallbackBarrier<NetworkServiceError>(blocksNumber: managers.count,
                                                               resultQueue: resultQueue,
                                                               completion: completion,
                                                               failure: failure)

            managers.forEach {
                $0.synchronizeRequiredSettings(completion: barrier.completion, failure: barrier.failure)
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

            self.projectDownloadManagers.forEach{ $0.start() }
            self.genericSettingsDownloadManager.start()
            self.projectUploadManagers.forEach{ $0.start() }
            self.requestsQueue.start()
        }
    }
}

private extension SynchronizationService {
}
