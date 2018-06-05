//
//  GenericSettingsDownloadManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 22/05/2018.
//

import Foundation
import RealmSwift

class GenericSettingsDownloadManager {
    private let downloadQueue: DownloadRequestsQueue

    init(downloadQueue: DownloadRequestsQueue) {
        self.downloadQueue = downloadQueue
    }

    func start() {
        updateSettings()
    }
}

extension GenericSettingsDownloadManager: DownloadManager {
    var areRequiredSettingsSynchronized: Bool {
        get {
            let realm = try! Realm.default()

            return realm.objects(TaskColor.self).count > 0
        }
    }

    func synchronizeRequiredSettings(completion: @escaping (() -> Void), failure: @escaping ((NetworkServiceError) -> Void)) {
        updateTaskColors(completion: completion, failure: failure)
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
