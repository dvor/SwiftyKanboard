//
//  BoardTaskDataSource.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/06/2018.
//

import RealmSwift

protocol BoardTaskDataSourceDelegate: class {
    func boardTaskUpdate(deleteSections: IndexSet, insertSections: IndexSet, reloadSections: IndexSet,
                         deleteItems: [IndexPath], insertItems: [IndexPath], reloadItems: [IndexPath])
}

class BoardTaskDataSource {
    private let projectId: String
    private let columns: Results<Column>
    private var columnsToken: NotificationToken!

    private var tasksByColumns = [ResultsSnapshot<Task>]()

    weak var delegate: BoardTaskDataSourceDelegate?

    init(projectId: String) {
        self.projectId = projectId

        let realm = try! Realm()
        let predicate = NSPredicate(format: "projectId == %@", projectId)
        self.columns = realm.objects(Column.self).filter(predicate).sorted(byKeyPath: "position")

        tasksByColumns = columns.map { createSnapshot(for: $0) }
        subscribeForNotifications()
    }

    var numberOfSections: Int {
        get {
            return tasksByColumns.count
        }
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        return tasksByColumns[section].snapshot.count
    }

    func item(at indexPath: IndexPath) -> Task {
        #if os(OSX)
        let row = indexPath.item
        #else
        let row = indexPath.row
        #endif
        return tasksByColumns[indexPath.section].snapshot[row]
    }
}

extension BoardTaskDataSource: ResultsSnapshotDelegate {
    func resultsSnapshotUpdated<T: Object>(snapshot: ResultsSnapshot<T>,
                                           deletions: [Int],
                                           insertions: [Int],
                                           modifications: [Int]) {

        guard let tasks = snapshot as? ResultsSnapshot<Task> else { return }
        guard let section = tasksByColumns.index(of: tasks) else { return }

        delegate?.boardTaskUpdate(deleteSections: IndexSet(),
                                  insertSections: IndexSet(),
                                  reloadSections: IndexSet(),
                                  deleteItems: deletions.map{ indexPath(for: $0, in: section) },
                                  insertItems: insertions.map{ indexPath(for: $0, in: section) },
                                  reloadItems: modifications.map{ indexPath(for: $0, in: section) })
    }
}

private extension BoardTaskDataSource {
    func subscribeForNotifications() {
        columnsToken = columns.observe{ [weak self] change in
            guard let `self` = self else { return }

            switch change {
            case .initial:
                break
            case .update(_, let deletions, let insertions, let modifications):
                self.handleColumnsUpdate(deletions: deletions, insertions: insertions, modifications: modifications)
            case .error(let error):
                log.warnMessage("Cannot update columns, \(error)")
            }
        }
    }

    func handleColumnsUpdate(deletions: [Int], insertions: [Int], modifications: [Int]) {
        for (index, delete) in deletions.enumerated() {
            let normalized = delete - index
            tasksByColumns.remove(at: normalized)
        }

        for insert in insertions {
            let snapshot = createSnapshot(for: columns[insert])
            tasksByColumns.insert(snapshot, at: insert)
        }

        delegate?.boardTaskUpdate(deleteSections: IndexSet(deletions),
                                  insertSections: IndexSet(insertions),
                                  reloadSections: IndexSet(modifications),
                                  deleteItems: [IndexPath](),
                                  insertItems: [IndexPath](),
                                  reloadItems: [IndexPath]())
    }

    func createSnapshot(for column: Column) -> ResultsSnapshot<Task> {
        let realm = try! Realm()

        let predicate = NSPredicate(format: "projectId == %@ AND columnId == %@ AND isActive == YES", projectId, column.id)
        let results = realm.objects(Task.self).filter(predicate)

        let snapshot = ResultsSnapshot(results: results)
        snapshot.delegate = self
        return snapshot
    }

    func indexPath(for row: Int, in section: Int) -> IndexPath {
        #if os(OSX)
        return IndexPath(item: row, section: section)
        #else
        return IndexPath(row: row, section: section)
        #endif
    }
}