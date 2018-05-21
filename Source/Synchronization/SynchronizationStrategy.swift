//
//  SynchronizationStrategy.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import Foundation

protocol SynchronizationStrategy {
    /// Delay between check for new operation when there are no operation in queue.
    var idleDelay: TimeInterval { get }

    /// Delays between synchronization attempts on failure. On each retry next/max value would be used.
    /// Example: [1, 1, 5, 10, 20]
    /// Delays used: 1, 1, 5, 10, 20, 20, ...
    var retryOnFailureDelays: [TimeInterval] { get }
}
