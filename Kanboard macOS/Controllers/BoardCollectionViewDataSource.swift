//
//  BoardCollectionViewDataSource.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import Foundation
import RealmSwift

class BoardCollectionViewDataSource: NSObject {
    private let collectionView: NSCollectionView
    private let projectId: String
    private let columns: Results<Column>
    private var columnsToken: NotificationToken!
    private var tasksByColumns: [Results<Task>]
    private var colors: Results<TaskColor>

    init(collectionView: NSCollectionView, projectId: String) {
        self.collectionView = collectionView
        self.projectId = projectId

        let realm = try! Realm()
        let predicate = NSPredicate(format: "projectId == %@", projectId)
        self.columns = realm.objects(Column.self).filter(predicate).sorted(byKeyPath: "position")
        self.tasksByColumns = [Results<Task>]()
        self.colors = realm.objects(TaskColor.self)

        super.init()

        self.columnsToken = columns.observe() { [weak self] change in
            switch change {
            case .initial:
                fallthrough
            case .update:
                self?.updateTasksByColumns()
            case .error(let error):
                log.warnMessage("Cannot update columns, \(error)")
            }
        }
    }
}

extension BoardCollectionViewDataSource: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return tasksByColumns.count
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasksByColumns[section].count
    }

    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: BoardCollectionViewItem.identifier, for: indexPath)
        guard let boardItem = item as? BoardCollectionViewItem else {
            fatalError("Wrong item passed")
        }

        let task = tasksByColumns[indexPath.section][indexPath.item]
        boardItem.name = task.title

        let predicate = NSPredicate(format: "id == %@", task.colorId)
        if let color = colors.filter(predicate).first {
            boardItem.backgroundColor = NSColor(red: CGFloat(color.backgroundRed),
                                                green: CGFloat(color.backgroundGreen),
                                                blue: CGFloat(color.backgroundBlue),
                                                alpha: 1.0)
        }

        boardItem.redraw()

        return boardItem
    }
}

private extension BoardCollectionViewDataSource {
    func updateTasksByColumns() {
        let realm = try! Realm()

        tasksByColumns = columns.map { column in
            let predicate = NSPredicate(format: "projectId == %@ AND columnId == %@ AND isActive == YES", projectId, column.id)

            return realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "position")
        }

        collectionView.reloadData()
    }
}
