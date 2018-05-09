//
//  RemoteProject.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

struct RemoteProject: Codable {
    let id: String
    let name: String?

    init(dict: [String:Any]) {
        id = dict["id"] as! String
        name = dict["name"] as? String
    }
}
