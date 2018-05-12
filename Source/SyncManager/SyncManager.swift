//
//  SyncManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Foundation
import RealmSwift

protocol SyncManagerDelegate: class {
    func userWasLoggedOut()
}

private struct Constants {
    static let updateInterval: TimeInterval = 60
}

class SyncManager {
    private let queue = DispatchQueue(label: "SyncManager queue", autoreleaseFrequency: .workItem)
    private var networkService: NetworkService!

    weak var delegate: SyncManagerDelegate?

    init() throws {
        // Create realm to handle possible errors early (migration, misconfiguration, etc).
        _ = try Realm.default()

        networkService = NetworkService(delegateQueue: self.queue)
    }

    func start() {
        doFullSync(after: .now())
    }
}

extension SyncManager {
    func doFullSync(after deadline: DispatchTime) {
        queue.asyncAfter(deadline: deadline) { [weak self] in
            self?.doFullSync()
        }
    }

    func doFullSync() {
        dispatchPrecondition(condition: .onQueue(queue))

        let request = networkService.createRequest(GetAllProjectsRequest.self) { [weak self] projects in
            guard let `self` = self else { return }

            self.projectsUpdate(projects)
            self.doFullSync(after: .now() + Constants.updateInterval)
        }

        networkService.batch([request])
    }

    func projectsUpdate(_ projects: [RemoteProject]) {
        dispatchPrecondition(condition: .onQueue(queue))
        let realm = try! Realm.default()
        let synchronizer = ProjectSynchronizer(realm: realm)

        for project in projects {
            _ = synchronizer.updateDatabase(with: project)
        }
    }
}
