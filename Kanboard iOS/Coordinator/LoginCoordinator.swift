//
//  LoginCoordinator.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import UIKit

protocol LoginCoordinatorDelegate: class {
    func loginCoordinatorDidLogin()
}

class LoginCoordinator: Coordinator {
    weak var delegate: LoginCoordinatorDelegate?

    init(window: UIWindow) {
        let controller = LoginViewController()
        controller.delegate = self

        window.rootViewController = controller
    }
}

extension LoginCoordinator: LoginViewControllerDelegate {
    func loginVCDidLogin() {
        delegate?.loginCoordinatorDidLogin()
    }
}
