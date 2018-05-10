//
//  RunningViewController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Cocoa

class RunningViewController: NSViewController {
    let service = NetworkService()

    init() {
        super.init(nibName: nil, bundle: nil)
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

        let r1 = service.createRequest(GetAllProjectsRequest.self) { projects in print(projects) }
        let r2 = service.createRequest(GetVersionRequest.self) { version in print(version) }
        service.batch([r1, r2])
    }
}
