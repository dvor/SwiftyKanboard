//
//  SelectProjectViewController.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import SnapKit
import UIKit

private struct Constants {
    static let cellIdentifier = "SelectProjectViewControllerCell"
}

protocol SelectProjectViewControllerDelegate: class {
    func selectProjectControllerDidSelect(projectId: String)
}

class SelectProjectViewController: UIViewController {
    private let networkService: NetworkService

    private var tableView: UITableView!
    private var projects = [RemoteProject]()

    weak var delegate: SelectProjectViewControllerDelegate?

    init(networkService: NetworkService) {
        self.networkService = networkService

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white

        createSubviews()
        makeConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if projects.isEmpty {
            downloadProjects()
        }
    }
}

extension SelectProjectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let project = projects[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        cell.textLabel!.text = project.name

        return cell
    }
}

extension SelectProjectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let project = projects[indexPath.row]
        delegate?.selectProjectControllerDidSelect(projectId: project.id)
    }
}

private extension SelectProjectViewController {
    func createSubviews() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        view.addSubview(tableView)
    }

    func makeConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }
    func downloadProjects() {
        let hud = ProgressHUD(type: .loading).show(in: view)

        let request = GetAllProjectsRequest(completion: { [weak self] projects in
            self?.projects = projects
            self?.tableView.reloadData()
            hud.dismiss()
        },
        failure: { error in
            // TODO handle error
            hud.dismiss()
        })

        networkService.batch([request], completion: nil, failure: nil)
    }
}
