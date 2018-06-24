//
//  SynchronizationService.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import Foundation
import RealmSwift

enum SynchronizationServiceError: Error {
    case wrongParameters
    // Server returned "false" for result.
    case requestFailed
    case networkError
}

@objc protocol SynchronizationServiceListener: class {
    @objc func synchronizationService(isSynchingChange isSyncing: Bool)
}

class SynchronizationService {
   private var listeners = NSHashTable<SynchronizationServiceListener>.weakObjects()

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

        requestsQueue.delegate = self
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

extension SynchronizationService {
    var isSyncing: Bool {
        get {
            return requestsQueue.requestsInProgress
        }
    }

    func addListener(_ listener: SynchronizationServiceListener) {
        listeners.add(listener)
    }

    func removeListener(_ listener: SynchronizationServiceListener) {
        listeners.remove(listener)
    }

    func move(taskId: String,
              to columnId: String,
              at position: Int,
              withoutNotifying notificationTokens: [NotificationToken],
              completion: (() -> Void)?,
              failure: ((SynchronizationServiceError) -> Void)?) {
        let realm = try! Realm.default()

        guard let task = realm.objects(Task.self).filter(NSPredicate(format: "id == %@", taskId)).first,
              let manager = projectUploadManagers.first(where: { $0.projectId == task.projectId }) else {

            DispatchQueue.main.async {
                failure?(.wrongParameters)
            }
            return
        }

        manager.move(taskId: taskId, to: columnId, at: position, withoutNotifying: notificationTokens, completion: {
            DispatchQueue.main.async {
                completion?()
            }
        }, failure: { error in
            DispatchQueue.main.async {
                failure?(error)
            }
        })
    }
}

extension SynchronizationService: RequestsQueueDelegate {
    func requestsQueue(_ queue: RequestsQueue, requestsInProgressUpdate requestsInProgress: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.listeners.allObjects.forEach {
                $0.synchronizationService(isSynchingChange: requestsInProgress)
            }
        }
    }
}

private extension SynchronizationService {
}
