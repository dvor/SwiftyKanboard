//
//  MainWindowController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 17/05/2018.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        updateContentViewController()
    }
}

extension MainWindowController: LoginViewControllerDelegate {
    func didLogin() {
        updateContentViewController()
    }
}

extension MainWindowController {
    func updateContentViewController() {
        if KeychainManager().isLoggedIn {
            contentViewController = RunningViewController()
        }
        else {
            let login = LoginViewController()
            login.delegate = self
            contentViewController = login
        }
    }
}
