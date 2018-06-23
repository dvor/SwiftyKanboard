//
//  ProjectUploadManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 22/05/2018.
//

import Foundation
import RealmSwift

class ProjectUploadManager {
    let projectId: String
    private let uploadQueue: UploadRequestsQueue

    init(projectId: String, uploadQueue: UploadRequestsQueue) {
        self.projectId = projectId
        self.uploadQueue = uploadQueue
    }

    func start() {

    }

    func move(taskId: String,
              to columnId: String,
              at position: Int,
              withoutNotifying notificationTokens: [NotificationToken],
              completion: (() -> Void)?,
              failure: ((SynchronizationServiceError) -> Void)?) {
        let realm = try! Realm.default()

        let task = realm.objects(Task.self).filter(NSPredicate(format: "id == %@", taskId)).first!
        let column = realm.objects(Column.self).filter(NSPredicate(format: "id == %@", columnId)).first!

        assert(task.projectId == projectId)
        assert(column.projectId == projectId)

        taskWasMoved(task, column: column, position: position, withoutNotifying: notificationTokens)

        let request = MoveTaskPositionRequest(projectId: projectId,
                                              taskId: task.id,
                                              columnId: column.id,
                                              position: position,
                                              swimlaneId: task.swimlaneId,
                                              completion: { result in
            if result {
                completion?()
            }
            else {
                failure?(.requestFailed)
            }
        }, failure: { error in
            failure?(.networkError)
        })

        uploadQueue.add(uploadRequest: request)
    }
}

private extension ProjectUploadManager {
    func taskWasMoved(_ movedTask: Task,
                      column: Column,
                      position: Int,
                      withoutNotifying notificationTokens: [NotificationToken]) {
        let realm = try! Realm.default()

        realm.beginWrite()

        var predicate = NSPredicate(format: "projectId == %@ AND columnId == %@ AND position > %i",
                                    projectId, movedTask.columnId, movedTask.position)

        for task in realm.objects(Task.self).filter(predicate) {
            task.position -= 1
        }

        predicate = NSPredicate(format: "projectId == %@ AND columnId == %@ AND position >= %i",
                                projectId, column.id, position)

        for task in realm.objects(Task.self).filter(predicate) {
            task.position += 1
        }

        movedTask.position = position
        movedTask.columnId = column.id

        do {
            try realm.commitWrite(withoutNotifying: notificationTokens)
        }
        catch let error as NSError {
            log.warnMessage("Cannot write to realm: \(error)")
        }
    }
}
