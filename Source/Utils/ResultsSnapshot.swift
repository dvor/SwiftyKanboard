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

// Whole idea of snapshoting is (sort of) terrible hack.
// It should be removed as soon as Realm will have grouping mechanism.
// See https://github.com/realm/realm-cocoa/issues/3384
class ResultsSnapshot<T: Object> {
    private let results: Results<T>
    var token: NotificationToken!

    private var snapshot = [T]()
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

    var count: Int {
        get {
            return snapshot.count
        }
    }

    func object(atIndex index: Int) -> T {
        var object = snapshot[index]

        if object.isInvalidated {
            // Snapshot may contain invalidated object.
            // Probably this object will be removed soon with updateSnapshot call.
            // Meanwhile we return a dummy empty object which is not added to the Realm.
            object = T()
        }

        return object
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
