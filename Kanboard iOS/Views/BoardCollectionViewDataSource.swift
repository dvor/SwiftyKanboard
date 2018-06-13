//
//  BoardCollectionViewDataSource.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/06/2018.
//

import UIKit
import RealmSwift

class BoardCollectionViewDataSource: NSObject {
    private weak var collectionView: UICollectionView?
    private let projectId: String
    private let columns: Results<Column>
    private var columnsToken: NotificationToken!
    private var tasksByColumns: [Results<Task>]
    private var colors: Results<TaskColor>

    init(collectionView: UICollectionView, projectId: String) {
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

extension BoardCollectionViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tasksByColumns.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasksByColumns[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCollectionViewCell.identifier,
                                                            for: indexPath) as? BoardCollectionViewCell else {
            fatalError("Wrong cell class")
        }

        let task = tasksByColumns[indexPath.section][indexPath.item]
        cell.label.text = task.title

        let predicate = NSPredicate(format: "id == %@", task.colorId)
        if let color = colors.filter(predicate).first {
            cell.contentView.backgroundColor = UIColor(red: CGFloat(color.backgroundRed),
                                                       green: CGFloat(color.backgroundGreen),
                                                       blue: CGFloat(color.backgroundBlue),
                                                       alpha: 1.0)
        }

        return cell
    }
}

private extension BoardCollectionViewDataSource {
    func updateTasksByColumns() {
        let realm = try! Realm()

        tasksByColumns = columns.map { column in
            let predicate = NSPredicate(format: "projectId == %@ AND columnId == %@ AND isActive == YES", projectId, column.id)

            return realm.objects(Task.self).filter(predicate).sorted(byKeyPath: "position")
        }

        collectionView?.reloadData()
    }
}
