//
//  AppCoordinator.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import UIKit

class AppCoordinator: Coordinator {
    private let window: UIWindow
    private var coordinator: Coordinator!

    init(window: UIWindow) {
        self.window = window

        updateCoordinator()
    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    func loginCoordinatorDidLogin() {
        updateCoordinator()
    }
}

private extension AppCoordinator {
    func updateCoordinator() {
        if KeychainManager().isLoggedIn {
            coordinator = RunningCoordinator(window: window)
        }
        else {
            let login = LoginCoordinator(window: window)
            login.delegate = self
            coordinator = login
        }
    }
}
