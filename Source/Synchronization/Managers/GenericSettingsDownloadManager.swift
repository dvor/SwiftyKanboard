//
//  GenericSettingsDownloadManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 22/05/2018.
//

import Foundation
import RealmSwift

class GenericSettingsDownloadManager {
    private let strategy: SynchronizationStrategy
    private let downloadQueue: DownloadRequestsQueue

    init(strategy: SynchronizationStrategy, downloadQueue: DownloadRequestsQueue) {
        self.strategy = strategy
        self.downloadQueue = downloadQueue
    }

    func areRequiredSettingsSynchronized() -> Bool {
        let realm = try! Realm.default()

        // For now we require only colors to be synced.
        return realm.objects(TaskColor.self).count > 0
    }

    func synchronizeRequiredSettings(completion: (() -> Void)?, failure: ((NetworkServiceError) -> Void)?) {
        updateTaskColors(completion: completion, failure: failure)
    }

    func start() {
        updateSettings()
    }
}

private extension GenericSettingsDownloadManager {
    func updateSettings() {
        updateTaskColors(completion: nil, failure: nil)
    }

    func updateTaskColors(completion: (() -> Void)?, failure: ((NetworkServiceError) -> Void)?) {
        let request = GetDefaultTaskColorsRequest(completion: { colors in
            let realm = try! Realm.default()

            let updater: DatabaseUpdater<RemoteTaskColor, TaskColor> = DatabaseUpdater(realm: realm)
            for color in colors {
                _ = updater.updateDatabase(with: color)
            }

            completion?()
        },
        failure: { error in
            failure?(error)
        })

        downloadQueue.add(downloadRequest: request, isConcurent: true)
    }
}
