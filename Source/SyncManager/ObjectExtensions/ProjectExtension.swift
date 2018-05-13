//
//  ProjectExtension.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation
import RealmSwift

extension Project: Synchronizable {
    func isEqual(to remote: RemoteObject) -> Bool {
        guard let project = remote as? RemoteProject else {
            fatalError("Passed object of wrong type")
        }

        return
            id                  == project.id &&
            name                == project.name &&
            projectDescription  == project.description &&
            defaultSwimlane     == project.defaultSwimlane &&
            showDefaultSwimlane == project.showDefaultSwimlane &&
            isActive            == project.isActive &&
            isPublic            == project.isPublic &&
            isPrivate           == project.isPrivate &&
            boardURLString      == project.boardURLString &&
            calendarURLString   == project.calendarURLString &&
            listURLString       == project.listURLString &&
            lastModified        == project.lastModified
    }

    func update(with remote: RemoteObject) {
        guard let project = remote as? RemoteProject else {
            fatalError("Passed object of wrong type")
        }

        name                = project.name
        projectDescription  = project.description
        defaultSwimlane     = project.defaultSwimlane
        showDefaultSwimlane = project.showDefaultSwimlane
        isActive            = project.isActive
        isPublic            = project.isPublic
        isPrivate           = project.isPrivate
        boardURLString      = project.boardURLString
        calendarURLString   = project.calendarURLString
        listURLString       = project.listURLString
        lastModified        = project.lastModified
    }
}
