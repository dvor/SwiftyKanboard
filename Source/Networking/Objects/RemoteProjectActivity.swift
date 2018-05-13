//
//  RemoteProjectActivity.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation

struct RemoteProjectActivity: RemoteObject {
    let id: String
    let creationDate: Date
    let eventName: String

    init(object: Any) throws {
        let dict = try DictionaryDecoder(object)

        id = try dict.value(forKey: "id")
        creationDate = try dict.date(forKey: "date_creation")
        eventName = try dict.value(forKey: "event_name")
    }
}
