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

        let keychain = KeychainManager()

        networkService = NetworkService(baseURL: URL(string: keychain.baseURL!)!,
                                        userName: keychain.userName!,
                                        apiToken: keychain.apiToken!,
                                        delegateQueue: self.queue)
    }

    func start() {
        doFullSyncAfterDelay(.now())
    }
}

private extension SyncManager {
    func doFullSyncAfterDelay(_ delay: DispatchTime = .now() + Constants.updateInterval) {
        queue.asyncAfter(deadline: delay) { [weak self] in
            self?.doFullSync()
        }
    }

    func doFullSync() {
        dispatchPrecondition(condition: .onQueue(queue))

        let request = GetAllProjectsRequest() { [weak self] projects in
            guard let `self` = self else { return }

            self.allProjectsRequestFinished(projects)
        }

        networkService.batch([request], completion: nil, failure:{ [weak self] error in
            log("Cannot perform full sync, error \(error)")
            self?.doFullSyncAfterDelay()
        })
    }

    func allProjectsRequestFinished(_ projects: [RemoteProject]) {
        dispatchPrecondition(condition: .onQueue(queue))
        let realm = try! Realm.default()
        let synchronizer: Synchronizer<RemoteProject, Project> = Synchronizer(realm: realm)

        var requests = [AbstractRequest]()

        for project in projects {
            let result = synchronizer.updateDatabase(with: project)

            switch result {
            case .internalError:
                break
            case .unchanged:
                break
            case .created:
                fallthrough
            case .updated:
                requests.append(updateColumnsRequest(for: project))
            }
        }

        if requests.isEmpty {
            doFullSyncAfterDelay()
            return
        }

        networkService.batch(requests, completion: { [weak self] in
            self?.doFullSyncAfterDelay()
        },
        failure:{ [weak self] error in
            log("Cannot perform full sync, error \(error)")
            self?.doFullSyncAfterDelay()
        })
    }

    func updateColumnsRequest(for project: RemoteProject) -> GetColumnsRequest {
        return GetColumnsRequest(projectId: project.id) { columns in
            let realm = try! Realm.default()

            let synchronizer: Synchronizer<RemoteColumn, Column> = Synchronizer(realm: realm)
            for column in columns {
                _ = synchronizer.updateDatabase(with: column)
            }
        }
    }
}
