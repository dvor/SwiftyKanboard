//
//  RemoteProject.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

struct RemoteProject: RemoteObject {
    let id: String
    let name: String
    let description: String?

    let defaultSwimlane: String
    let showDefaultSwimlane: Bool

    let isActive: Bool
    let isPublic: Bool
    let isPrivate: Bool

    let boardURLString: String?
    let calendarURLString: String?
    let listURLString: String?

    let lastModified: Date
}
