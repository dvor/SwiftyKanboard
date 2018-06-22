//
//  TaskExtension.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

extension Task: Updatable {
    func isEqual(to remote: RemoteObject) -> Bool {
        guard let task = remote as? RemoteTask else {
            fatalError("Passed object of wrong type")
        }

        return
            id               == task.id &&
            title            == task.title &&
            taskDescription  == task.description &&
            urlString        == task.urlString &&
            isActive         == task.isActive &&
            position         == task.position &&
            score.value      == task.score &&
            priority         == task.priority &&
            colorId          == task.colorId &&
            projectId        == task.projectId &&
            columnId         == task.columnId &&
            ownerId          == task.ownerId &&
            creatorId        == task.creatorId &&
            categoryId       == task.categoryId &&
            swimlaneId       == task.swimlaneId &&
            creationDate     == task.creationDate &&
            startedDate      == task.startedDate &&
            dueDate          == task.dueDate &&
            modificationDate == task.modificationDate &&
            movedDate        == task.movedDate &&
            completedDate    == task.completedDate
    }

    func update(with remote: RemoteObject) {
        guard let task = remote as? RemoteTask else {
            fatalError("Passed object of wrong type")
        }

        title            = task.title
        taskDescription  = task.description
        urlString        = task.urlString
        isActive         = task.isActive
        position         = task.position
        score.value      = task.score
        priority         = task.priority
        colorId          = task.colorId
        projectId        = task.projectId
        columnId         = task.columnId
        ownerId          = task.ownerId
        creatorId        = task.creatorId
        categoryId       = task.categoryId
        swimlaneId       = task.swimlaneId
        creationDate     = task.creationDate
        startedDate      = task.startedDate
        dueDate          = task.dueDate
        modificationDate = task.modificationDate
        movedDate        = task.movedDate
        completedDate    = task.completedDate
    }
}
