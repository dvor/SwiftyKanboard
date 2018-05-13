//
//  ColumnExtension.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

extension Column: Synchronizable {
    func isEqual(to remote: RemoteObject) -> Bool {
        guard let column = remote as? RemoteColumn else {
            fatalError("Passed object of wrong type")
        }

        return
            id        == column.id &&
            title     == column.title &&
            projectId == column.projectId &&
            position  == column.position &&
            taskLimit == column.taskLimit
    }

    func update(with remote: RemoteObject) {
        guard let column = remote as? RemoteColumn else {
            fatalError("Passed object of wrong type")
        }

        title     = column.title
        projectId = column.projectId
        position  = column.position
        taskLimit = column.taskLimit
    }
}
