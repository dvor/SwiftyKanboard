//
//  BoardViewController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import UIKit
import SnapKit

private struct Constants {
    static let horizontalOffsetFromEdge: CGFloat = 25.0
}

class BoardViewController: UIViewController {
    private let synchronizationService: SynchronizationService
    private let projectId: String

    private var dataSource: BoardCollectionViewDataSource!
    private var collectionView: UICollectionView!

    private var oldContentOffset: CGPoint?

    init(synchronizationService: SynchronizationService, projectId: String) {
        self.synchronizationService = synchronizationService
        self.projectId = projectId

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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        synchronizationService.startSynchronization()
    }
}

extension BoardViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        oldContentOffset = scrollView.contentOffset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let oldContentOffset = oldContentOffset else { return }

        if abs(scrollView.contentOffset.x - oldContentOffset.x) > abs(scrollView.contentOffset.y - oldContentOffset.y) {
            scrollView.decelerationRate = UIScrollViewDecelerationRateFast
            scrollView.contentOffset.y = oldContentOffset.y
            scrollView.showsHorizontalScrollIndicator = true
            scrollView.showsVerticalScrollIndicator = false
        }
        else {
            scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
            scrollView.contentOffset.x = oldContentOffset.x
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = true
        }
    }
}

private extension BoardViewController {
    func createSubviews() {
        let layout = BoardCollectionViewLayout(horizontalOffsetFromEdge: Constants.horizontalOffsetFromEdge)

        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.isDirectionalLockEnabled = true
        collectionView.contentInset.left = Constants.horizontalOffsetFromEdge
        collectionView.contentInset.right = Constants.horizontalOffsetFromEdge
        collectionView.register(BoardCollectionViewCell.self,
                                forCellWithReuseIdentifier: BoardCollectionViewCell.identifier)
        view.addSubview(collectionView)

        dataSource = BoardCollectionViewDataSource(collectionView: collectionView, projectId: projectId)
        collectionView.dataSource = dataSource
    }

    func makeConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }
}
