//
//  ResultsSnapshot.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/06/2018.
//

import RealmSwift

protocol ResultsSnapshotDelegate: class {
    func resultsSnapshotUpdated<T: Object>(snapshot: ResultsSnapshot<T>,
                                           deletions: [Int],
                                           insertions: [Int],
                                           modifications: [Int])
}

class ResultsSnapshot<T: Object> {
    private let results: Results<T>
    var token: NotificationToken!

    private(set) var snapshot = [T]()
    weak var delegate: ResultsSnapshotDelegate?

    init(results: Results<T>) {
        self.results = results
        self.token = results.observe{ [weak self] change in
            guard let `self` = self else { return }

            switch change {
            case .initial:
                break
            case .update(_, let deletions, let insertions, let modifications):
                self.updateSnapshot()
                self.delegate?.resultsSnapshotUpdated(snapshot: self,
                                                      deletions: deletions,
                                                      insertions: insertions,
                                                      modifications: modifications)
            case .error(let error):
                log.warnMessage("Cannot update columns, \(error)")
            }
        }

        updateSnapshot()
    }

    func updateSnapshot() {
        self.snapshot = results.map{ $0 }
    }
}

extension ResultsSnapshot: Equatable {
    static func == (lhs: ResultsSnapshot<T>, rhs: ResultsSnapshot<T>) -> Bool {
        return lhs === rhs
    }
}
