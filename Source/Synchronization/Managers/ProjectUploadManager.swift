//
//  ProjectUploadManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 22/05/2018.
//

import Foundation

class ProjectUploadManager {
    private let projectId: String
    private let uploadQueue: UploadRequestsQueue

    init(projectId: String, uploadQueue: UploadRequestsQueue) {
        self.projectId = projectId
        self.uploadQueue = uploadQueue
    }

    func start() {

    }
}
