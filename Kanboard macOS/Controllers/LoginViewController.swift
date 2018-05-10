//
//  LoginViewController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Cocoa
import SnapKit

protocol LoginViewControllerDelegate: class {
    func didLogin()
}

class LoginViewController: NSViewController {
    var containerView: NSView!
    var baseURLField: NSTextField!
    var userNameField: NSTextField!
    var apiTokenField: NSTextField!
    var loginButton: NSButton!

    weak var delegate: LoginViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: CGRect(x: 0, y: 0, width: 600, height: 300))
        createViews()
        installConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

// MARK: Actions
extension LoginViewController {
    @objc func loginButtonPressed() {
        let keychain = KeychainManager()
        keychain.baseURL = baseURLField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        keychain.userName = userNameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        keychain.apiToken = apiTokenField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)

        delegate?.didLogin()
    }
}

private extension LoginViewController {
    func createViews() {
        containerView = NSView()
        view.addSubview(containerView)

        baseURLField = NSTextField()
        baseURLField.placeholderString = "Base URL"
        view.addSubview(baseURLField)

        userNameField = NSTextField()
        userNameField.placeholderString = "Username"
        view.addSubview(userNameField)

        apiTokenField = NSTextField()
        apiTokenField.placeholderString = "API token"
        view.addSubview(apiTokenField)

        loginButton = NSButton(title: "Login",
                               target: self,
                               action: #selector(LoginViewController.loginButtonPressed))
        view.addSubview(loginButton)
    }

    func installConstraints() {
        containerView.snp.makeConstraints {
            $0.center.equalTo(view)
        }

        baseURLField.snp.makeConstraints {
            $0.top.equalTo(containerView)
            $0.left.right.equalTo(containerView)
            $0.width.equalTo(300)
            $0.height.equalTo(20)
        }

        userNameField.snp.makeConstraints {
            $0.top.equalTo(baseURLField.snp.bottom).offset(8)
            $0.left.right.equalTo(containerView)
            $0.height.equalTo(baseURLField)
        }

        apiTokenField.snp.makeConstraints {
            $0.top.equalTo(userNameField.snp.bottom).offset(8)
            $0.left.right.equalTo(containerView)
            $0.height.equalTo(baseURLField)
        }

        loginButton.snp.makeConstraints {
            $0.top.equalTo(apiTokenField.snp.bottom).offset(8)
            $0.centerX.equalTo(containerView)
            $0.bottom.equalTo(containerView)
            $0.width.equalTo(100)
            $0.height.equalTo(20)
        }
    }
}
