//
//  ProjectSyncManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Foundation
import RealmSwift

protocol ProjectSyncManagerDelegate: class {
    func userWasLoggedOut()
}

private struct Constants {
    static let updateInterval: TimeInterval = 60
}

class ProjectSyncManager {
    private let queue = DispatchQueue(label: "ProjectSyncManager queue", autoreleaseFrequency: .workItem)
    private var networkService: NetworkService!

    private let projectId: String

    weak var delegate: ProjectSyncManagerDelegate?

    init(projectId: String) throws {
        self.projectId = projectId

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

private extension ProjectSyncManager {
    func doFullSyncAfterDelay(_ delay: DispatchTime = .now() + Constants.updateInterval) {
        queue.asyncAfter(deadline: delay) { [weak self] in
            self?.doFullSync()
        }
    }

    func doFullSync() {
        dispatchPrecondition(condition: .onQueue(queue))

        let projects = updateProjectRequest()
        let columns = updateColumnsRequest()
        let activeTasks = updateTasksRequest(active: true)
        let nonActiveTasks = updateTasksRequest(active: false)
        let colors = updateColorsRequest()

        networkService.batch([projects, columns, activeTasks, nonActiveTasks, colors], completion: { [weak self] in
            self?.doFullSyncAfterDelay()
        },
        failure:{ [weak self] error in
            log("Cannot perform full sync, error \(error)")
            self?.doFullSyncAfterDelay()
        })
    }

    func updateProjectRequest() -> GetProjectByIdRequest {
        return GetProjectByIdRequest(projectId: projectId) { project in
            let realm = try! Realm.default()

            let synchronizer: Synchronizer<RemoteProject, Project> = Synchronizer(realm: realm)
            _ = synchronizer.updateDatabase(with: project)
        }
    }

    func updateColumnsRequest() -> GetColumnsRequest {
        return GetColumnsRequest(projectId: projectId) { columns in
            let realm = try! Realm.default()

            let synchronizer: Synchronizer<RemoteColumn, Column> = Synchronizer(realm: realm)
            for column in columns {
                _ = synchronizer.updateDatabase(with: column)
            }
        }
    }

    func updateTasksRequest(active: Bool) -> GetAllTasksRequest {
        return GetAllTasksRequest(projectId: projectId, active: active) { columns in
            let realm = try! Realm.default()

            let synchronizer: Synchronizer<RemoteTask, Task> = Synchronizer(realm: realm)
            for column in columns {
                _ = synchronizer.updateDatabase(with: column)
            }
        }
    }

    func updateColorsRequest() -> GetDefaultTaskColorsRequest {
        return GetDefaultTaskColorsRequest() { colors in
            let realm = try! Realm.default()

            let synchronizer: Synchronizer<RemoteTaskColor, TaskColor> = Synchronizer(realm: realm)
            for color in colors {
                _ = synchronizer.updateDatabase(with: color)
            }
        }
    }
}
