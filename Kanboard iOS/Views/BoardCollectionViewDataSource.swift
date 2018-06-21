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

    private var taskDataSource: BoardTaskDataSource
    private var colors: Results<TaskColor>

    init(collectionView: UICollectionView, projectId: String) {
        self.collectionView = collectionView

        let realm = try! Realm()
        taskDataSource = BoardTaskDataSource(projectId: projectId)
        colors = realm.objects(TaskColor.self)

        super.init()

        taskDataSource.delegate = self
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

        let task = taskDataSource.item(at: indexPath)
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
}

