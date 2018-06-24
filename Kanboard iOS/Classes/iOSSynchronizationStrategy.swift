//
//  iOSSynchronizationStrategy.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 03/06/2018.
//

import Foundation

struct iOSSynchronizationStrategy: SynchronizationStrategy {
    let idleDelay: TimeInterval = 0.1

    let retryOnFailureDelays: [TimeInterval] = [2.0, 5.0, 20.0, 60.0]
}
