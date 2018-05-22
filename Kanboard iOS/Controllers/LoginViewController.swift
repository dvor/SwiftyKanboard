//
//  LoginViewController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import UIKit
import SnapKit

private struct Constants {
    static let width = 300
    static let topOffset = -100
    static let offset = 8
}

protocol LoginViewControllerDelegate: class {
    func loginVCDidLogin()
}

class LoginViewController: UIViewController {
    private var container: UIView!
    private var baseURLField: UITextField!
    private var userNameField: UITextField!
    private var apiTokenField: UITextField!
    private var loginButton: UIButton!

    private var networkService: NetworkService?

    weak var delegate: LoginViewControllerDelegate?

    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white

        createSubviews()
        installConstraints()
    }
}

// MARK: Actions
extension LoginViewController {
    @objc func loginButtonPressed() {
        let hud = ProgressHUD(type: .loading).show(in: view)

        // TODO validate values
        let baseURLString = baseURLField.text!
        let baseURL = URL(string: baseURLString)!
        let userName = userNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let apiToken = apiTokenField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        networkService = NetworkService(baseURL: baseURL,
                                        userName: userName,
                                        apiToken: apiToken,
                                        delegateQueue: DispatchQueue.main)

        let request = GetVersionRequest(completion: { [weak self] _ in
            let keychain = KeychainManager()
            keychain.baseURL = baseURLString
            keychain.userName = userName
            keychain.apiToken = apiToken

            hud.dismiss()
            self?.delegate?.loginVCDidLogin()
        },
        failure: { error in
            log.infoMessage("\(error)")
            hud.dismiss()
        })

        networkService?.batch([request], completion: nil, failure: nil)
    }
}

private extension LoginViewController {
    func createSubviews() {
        container = UIView()
        view.addSubview(container)

        baseURLField = UITextField()
        baseURLField.placeholder = String(localized: "base_url_placeholder")
        baseURLField.keyboardType = .URL
        baseURLField.borderStyle = .line
        container.addSubview(baseURLField)

        userNameField = UITextField()
        userNameField.placeholder = String(localized: "user_name_placeholder")
        userNameField.borderStyle = .line
        container.addSubview(userNameField)

        apiTokenField = UITextField()
        apiTokenField.placeholder = String(localized: "api_token_placeholder")
        apiTokenField.borderStyle = .line
        container.addSubview(apiTokenField)

        loginButton = UIButton(type: .system)
        loginButton.setTitle(String(localized: "login_button_title"), for: .normal)
        loginButton.addTarget(self, action: #selector(LoginViewController.loginButtonPressed), for: .touchUpInside)
        container.addSubview(loginButton)
    }

    func installConstraints() {
        container.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.centerY.equalTo(view).offset(Constants.topOffset)
            $0.width.equalTo(Constants.width)
        }

        baseURLField.snp.makeConstraints {
            $0.top.equalTo(container)
            $0.left.right.equalTo(container)
        }

        userNameField.snp.makeConstraints {
            $0.top.equalTo(baseURLField.snp.bottom).offset(Constants.offset)
            $0.left.right.equalTo(container)
        }

        apiTokenField.snp.makeConstraints {
            $0.top.equalTo(userNameField.snp.bottom).offset(Constants.offset)
            $0.left.right.equalTo(container)
        }

        loginButton.snp.makeConstraints {
            $0.top.equalTo(apiTokenField.snp.bottom).offset(Constants.offset)
            $0.left.right.equalTo(container)
            $0.bottom.equalTo(container)
        }
    }
}
