//
//  RunningCoordinator.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import UIKit

// TODO handle errors in this class
// TODO handle logout
class RunningCoordinator: NSObject, Coordinator {
    private let navigationController: UINavigationController

    init(window: UIWindow) {
        self.navigationController = UINavigationController()

        super.init()

        navigationController.delegate = self
        pushSelectProjectController()

        if let projectId = UserDefaultsManager().activeProjectId {
            pushBoardController(projectId: projectId, animated: false)
        }

        window.rootViewController = navigationController
    }
}

extension RunningCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        if viewController is SelectProjectViewController {
            UserDefaultsManager().activeProjectId = nil
        }
    }
}

extension RunningCoordinator: SelectProjectViewControllerDelegate {
    func selectProjectControllerDidSelect(projectId: String) {
        pushBoardController(projectId: projectId, animated: true)
    }
}

private extension RunningCoordinator {
    func credentials() -> (baseURL: URL, userName: String, apiToken: String) {
        let keychain = KeychainManager()

        return (baseURL: URL(string: keychain.baseURL!)!,
                userName: keychain.userName!,
                apiToken: keychain.apiToken!)
    }

    func pushSelectProjectController() {
        let credentials = self.credentials()

        let networkService = NetworkService(baseURL: credentials.baseURL,
                                            userName: credentials.userName,
                                            apiToken: credentials.apiToken,
                                            delegateQueue: DispatchQueue.main)

        let controller = SelectProjectViewController(networkService: networkService)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: false)
    }

    func pushBoardController(projectId: String, animated: Bool) {
        let credentials = self.credentials()

        let service = try! SynchronizationService(projectIds: [projectId],
                                                  strategy: iOSSynchronizationStrategy(),
                                                  baseURL: credentials.baseURL,
                                                  userName: credentials.userName,
                                                  apiToken: credentials.apiToken)

        let createController = { [weak self] in
            UserDefaultsManager().activeProjectId = projectId

            guard let controller = BoardViewController(synchronizationService: service, projectId: projectId) else {
                // TODO handle error
                return
            }
            self?.navigationController.pushViewController(controller, animated: animated)
        }

        if service.areRequiredSettingsSynchronized {
            createController()
            return
        }

        let hud = ProgressHUD(type: .loading).show(in: navigationController.view)

        service.synchronizeRequiredSettings(resultQueue: DispatchQueue.main, completion: {
            hud.dismiss()
            createController()
        }, failure: { error in
            // TODO handle error
            hud.dismiss()
        })
    }
}
