//
//  RunningCoordinator.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import UIKit

// TODO handle errors in this class
// TODO handle logout
class RunningCoordinator: Coordinator {
    private let navigationController: UINavigationController

    init(window: UIWindow) {
        navigationController = UINavigationController()
        window.rootViewController = navigationController

        pushSelectProjectController()
    }
}

extension RunningCoordinator: SelectProjectViewControllerDelegate {
    func selectProjectControllerDidSelect(projectId: String) {
        showBoardController(projectId: projectId)
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

    func showBoardController(projectId: String) {
        let credentials = self.credentials()

        let service = try! SynchronizationService(projectIds: [projectId],
                                                  strategy: iOSSynchronizationStrategy(),
                                                  baseURL: credentials.baseURL,
                                                  userName: credentials.userName,
                                                  apiToken: credentials.apiToken)

        let createController = { [weak self] in
            let controller = BoardViewController(synchronizationService: service, projectId: projectId)
            self?.navigationController.pushViewController(controller, animated: true)
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
