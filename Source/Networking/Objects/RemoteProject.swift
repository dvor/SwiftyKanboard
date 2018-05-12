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
    let lastModified: Date

    init(dict: [String:Any]) {
        id = dict["id"] as! String
        name = dict["name"] as! String

        let modified = TimeInterval(dict["last_modified"] as! String)!
        lastModified = Date(timeIntervalSince1970: modified)
    }
}
