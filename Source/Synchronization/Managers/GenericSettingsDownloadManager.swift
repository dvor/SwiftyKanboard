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

    func start() {
        updateSettings()
    }
}

private extension GenericSettingsDownloadManager {
    func updateSettings() {
        let request = GetDefaultTaskColorsRequest(completion: { colors in
            let realm = try! Realm.default()

            let updater: DatabaseUpdater<RemoteTaskColor, TaskColor> = DatabaseUpdater(realm: realm)
            for color in colors {
                _ = updater.updateDatabase(with: color)
            }
        }, failure: { _ in})

        downloadQueue.add(downloadRequest: request, isConcurent: true)
    }
}
