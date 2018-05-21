//
//  MacSynchronizationStrategy.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import Foundation

struct MacSynchronizationStrategy: SynchronizationStrategy {
    let idleDelay: TimeInterval = 1.0

    let retryOnFailureDelays: [TimeInterval] = [2.0, 5.0, 20.0, 60.0]
}
