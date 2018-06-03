//
//  CallbackBarrier.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 03/06/2018.
//

import Foundation

// Barrier can be used for synchronizing calls to async api.
class CallbackBarrier<FailureType> {
    private enum CallbackType {
        case completion
        case failure(FailureType)
    }

    private var syncQueue: DispatchQueue? = DispatchQueue(label: "CallbackBarrier queue")

    private var blocksNumber: Int
    private let resultQueue: DispatchQueue
    private let completionBlock: (() -> Void)?
    private let failureBlock: ((FailureType) -> Void)?

    init(blocksNumber: Int,
         resultQueue: DispatchQueue,
         completion: (() -> Void)?,
         failure: ((FailureType) -> Void)?) {
        self.blocksNumber = blocksNumber
        self.resultQueue = resultQueue
        self.completionBlock = completion
        self.failureBlock = failure
    }

    func completion() {
        callbackCalled(with: .completion)
    }

    func failure(error: FailureType) {
        callbackCalled(with: .failure(error))
    }

    private func callbackCalled(with type: CallbackType) {
        syncQueue?.async { // Capturing self in syncQueue
            guard self.blocksNumber > 0 else { return }

            switch type {
            case .completion:
                self.blocksNumber -= 1
            case .failure:
                // On error we fail immediately, without waiting for other blocks.
                self.blocksNumber = 0
            }

            guard self.blocksNumber == 0 else { return }

            let resultQueue = self.resultQueue
            let completionBlock = self.completionBlock
            let failureBlock = self.failureBlock

            // Releasing syncQueue to release self and avoit retain cycle
            self.syncQueue = nil

            resultQueue.async {
                switch type {
                case .completion:
                    completionBlock?()
                case .failure(let error):
                    failureBlock?(error)
                }
            }
        }
    }
}

