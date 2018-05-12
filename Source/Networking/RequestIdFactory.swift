//
//  RequestIdFactory.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 12/05/2018.
//

import Foundation

typealias RequestId = Int64

class RequestIdFactory {
    static private var current: RequestId = 1
    static private let syncQueue = DispatchQueue(label: "RequestIdFactory syncQueue")

    static func next() -> RequestId {
        var result: RequestId = 0

        syncQueue.sync {
            result = current
            current += 1
        }

        return result
    }
}
