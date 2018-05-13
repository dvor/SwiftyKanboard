//
//  RunningViewController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Cocoa

class RunningViewController: NSViewController {
    private let syncManager: ProjectSyncManager?

    init() {
        var syncManager: ProjectSyncManager? = nil

        do {
            syncManager = try ProjectSyncManager(projectId: "5")
        } catch let error as NSError {
            let alert = NSAlert(error: error)
            alert.runModal()
        }

        self.syncManager = syncManager
        super.init(nibName: nil, bundle: nil)

        syncManager?.delegate = self
        syncManager?.start()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: CGRect(x: 0, y: 0, width: 600, height: 300))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

extension RunningViewController: ProjectSyncManagerDelegate {
    func userWasLoggedOut() {
        log("Logout")
    }
}
