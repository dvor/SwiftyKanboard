//
//  BoardViewController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import UIKit

class BoardViewController: UIViewController {
    private let synchronizationService: SynchronizationService

    init(synchronizationService: SynchronizationService) {
        self.synchronizationService = synchronizationService

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .red

        createSubviews()
        installConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

private extension BoardViewController {
    func createSubviews() {

    }

    func installConstraints() {

    }
}
