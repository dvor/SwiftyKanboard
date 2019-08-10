//
//  BoardViewController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import UIKit
import SnapKit
import RealmSwift

private struct Constants {
    static let horizontalOffsetFromEdge: CGFloat = 25.0
}

class BoardViewController: UIViewController {
    private let synchronizationService: SynchronizationService
    private let project: Project

    private var layout: BoardCollectionViewLayout!
    private var dataSource: BoardCollectionViewDataSource!
    private var collectionView: UICollectionView!

    private var syncAnimatedButton: SyncAnimatedButton!

    private var oldContentOffset: CGPoint?

    init?(synchronizationService: SynchronizationService, projectId: String) {
        let realm = try! Realm.default()
        guard let project = realm.objects(Project.self).filter(NSPredicate(format: "id == %@", projectId)).first else {
            return nil
        }

        self.synchronizationService = synchronizationService
        self.project = project

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white

        createSubviews()
        makeConstraints()
        addNavigationItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        synchronizationService.addListener(self)
        synchronizationService.startSynchronization()

        syncAnimatedButton.isAnimating = synchronizationService.isSyncing

        if let lastActiveColumn = project.localInfo?.lastActiveColumn {
            view.layoutIfNeeded()
            layout.setVisibleColumn(lastActiveColumn, animated: true)
        }
    }
}

// MARK: Actions
extension BoardViewController {
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: indexPath)
            layout.isMovingItem = true
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
            layout.isMovingItem = false
        default:
            collectionView.cancelInteractiveMovement()
            layout.isMovingItem = false
        }
    }

    @objc func syncButtonPressed() {
        synchronizationService.synchronizeNow()
    }
}

extension BoardViewController: SynchronizationServiceListener {
    @objc func synchronizationService(isSynchingChange isSyncing: Bool) {
        syncAnimatedButton.isAnimating = isSyncing
    }
}

extension BoardViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        oldContentOffset = scrollView.contentOffset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let oldContentOffset = oldContentOffset else { return }

        if abs(scrollView.contentOffset.x - oldContentOffset.x) > abs(scrollView.contentOffset.y - oldContentOffset.y) {
            scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
            scrollView.contentOffset.y = oldContentOffset.y
            scrollView.showsHorizontalScrollIndicator = true
            scrollView.showsVerticalScrollIndicator = false
        }
        else {
            scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
            scrollView.contentOffset.x = oldContentOffset.x
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = true
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            saveVisibleColumn()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        saveVisibleColumn()
    }
}

extension BoardViewController: BoardCollectionViewDataSourceDelegate {
    func move(task: Task,
              to column: Column,
              position: Int,
              withoutNotifying notificationTokens: [NotificationToken],
              completion: @escaping (() -> Void),
              failure: @escaping (() -> Void)) {
        synchronizationService.move(taskId: task.id,
                                    to: column.id,
                                    at: position,
                                    withoutNotifying: notificationTokens,
                                    completion: completion,
                                    failure: { _ in
            // TODO handle error
            failure()
        })
    }
}

extension BoardViewController: BoardCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemAt indexPath: IndexPath,
                        forWidth width: CGFloat) -> CGFloat {
        return dataSource.heightForItem(at: indexPath, forWidth: width)
    }
}

private extension BoardViewController {
    func createSubviews() {
        layout = BoardCollectionViewLayout(horizontalOffsetFromEdge: Constants.horizontalOffsetFromEdge)
        layout.delegate = self

        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.isDirectionalLockEnabled = true
        collectionView.contentInset.left = Constants.horizontalOffsetFromEdge
        collectionView.contentInset.right = Constants.horizontalOffsetFromEdge
        collectionView.register(BoardCollectionViewCell.self,
                                forCellWithReuseIdentifier: BoardCollectionViewCell.identifier)
        view.addSubview(collectionView)

        dataSource = BoardCollectionViewDataSource(collectionView: collectionView, projectId: project.id)
        dataSource.delegate = self
        collectionView.dataSource = dataSource

        let recognizer = UILongPressGestureRecognizer(target: self,
                                                      action: #selector(BoardViewController.handleLongGesture))
        recognizer.minimumPressDuration = 0.3
        collectionView.addGestureRecognizer(recognizer)
    }

    func makeConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }

    func addNavigationItems() {
        syncAnimatedButton = SyncAnimatedButton()
        syncAnimatedButton.addTarget(self, action: #selector(BoardViewController.syncButtonPressed), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: syncAnimatedButton)
    }

    func saveVisibleColumn() {
        let realm = try! Realm.default()

        try? realm.write {
            project.createLocalInfoIfNeeded().lastActiveColumn = layout.visibleColumn
        }
    }
}
