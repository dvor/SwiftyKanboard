//
//  BoardCollectionViewDataSource.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/06/2018.
//

import UIKit
import RealmSwift

protocol BoardCollectionViewDataSourceDelegate: class {
    func move(task: Task,
              to: Column,
              position: Int,
              withoutNotifying notificationTokens: [NotificationToken],
              completion: @escaping (() -> Void),
              failure: @escaping (() -> Void))
}

class BoardCollectionViewDataSource: NSObject {
    private weak var collectionView: UICollectionView?
    private let dummySizingCell = BoardCollectionViewCell()

    private var taskDataSource: BoardTaskDataSource
    private var colors: Results<TaskColor>

    weak var delegate: BoardCollectionViewDataSourceDelegate!

    init(collectionView: UICollectionView, projectId: String) {
        self.collectionView = collectionView

        let realm = try! Realm()
        taskDataSource = BoardTaskDataSource(projectId: projectId)
        colors = realm.objects(TaskColor.self)

        super.init()

        taskDataSource.delegate = self
    }

    func getTask(at indexPath: IndexPath) -> Task {
        return taskDataSource.item(at: indexPath)
    }

    func heightForItem(at indexPath: IndexPath, forWidth width: CGFloat) -> CGFloat {
        let task = getTask(at: indexPath)
        fillCell(dummySizingCell, with: task)
        dummySizingCell.titleLabel.preferredMaxLayoutWidth = width

        let size = dummySizingCell.systemLayoutSizeFitting(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return size.height
    }
}

extension BoardCollectionViewDataSource: BoardTaskDataSourceDelegate {
    func boardTaskUpdate(deleteSections: IndexSet, insertSections: IndexSet, reloadSections: IndexSet,
                         deleteItems: [IndexPath], insertItems: [IndexPath], reloadItems: [IndexPath]) {
        guard let collectionView = collectionView else { return }

        collectionView.performBatchUpdates({
            collectionView.deleteSections(deleteSections)
            collectionView.insertSections(insertSections)
            collectionView.reloadSections(reloadSections)
            collectionView.deleteItems(at: deleteItems)
            collectionView.insertItems(at: insertItems)
            collectionView.reloadItems(at: reloadItems)
        })
    }
}

extension BoardCollectionViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return taskDataSource.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskDataSource.numberOfItemsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCollectionViewCell.identifier,
                                                            for: indexPath) as? BoardCollectionViewCell else {
            fatalError("Wrong cell class")
        }

        let task = getTask(at: indexPath)
        fillCell(cell, with: task)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        disableUserInteraction()

        let task = getTask(at: sourceIndexPath)
        let column = taskDataSource.column(at: destinationIndexPath.section)
        let position = destinationIndexPath.row + 1
        let tasksTokens = taskDataSource.tasksNotificationTokens

        delegate.move(task: task,
                      to: column,
                      position: position,
                      withoutNotifying: tasksTokens,
                      completion: enableUserInteraction,
                      failure: { [weak self] in
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [destinationIndexPath])
                collectionView.insertItems(at: [sourceIndexPath])
            })
            self?.enableUserInteraction()
        })

        taskDataSource.reloadTasks(in: sourceIndexPath.section)
        taskDataSource.reloadTasks(in: destinationIndexPath.section)
    }
}

private extension BoardCollectionViewDataSource {
    func disableUserInteraction() {
        collectionView?.isUserInteractionEnabled = false
        collectionView?.alpha = 0.8
    }

    func enableUserInteraction() {
        collectionView?.isUserInteractionEnabled = true
        collectionView?.alpha = 1.0
    }

    func fillCell(_ cell: BoardCollectionViewCell, with task: Task) {
        cell.idLabel.text = "#" + task.id
        cell.titleLabel.text = task.title
        cell.priorityLabel.text = "P\(task.priority)"

        let predicate = NSPredicate(format: "id == %@", task.colorId)
        if let color = colors.filter(predicate).first {
            cell.backgroundColor = color.backgroundColor
            cell.borderColor = color.borderColor
        }
    }
}

