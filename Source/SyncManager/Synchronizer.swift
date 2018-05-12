//
//  Synchronizer.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 11/05/2018.
//

import Foundation

enum SynchronizerResult {
    case internalError
    case unchanged
    case created
    case updated
}

protocol Synchronizer {
    associatedtype R: RemoteObject

    func updateDatabase(with object: R) -> SynchronizerResult
}
