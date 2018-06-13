//
//  BoardViewController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import UIKit
import SnapKit

class BoardViewController: UIViewController {
    private let synchronizationService: SynchronizationService
    private let projectId: String

    private var dataSource: BoardCollectionViewDataSource!
    private var collectionView: UICollectionView!

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

private extension BoardViewController {
    func createSubviews() {
        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
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
