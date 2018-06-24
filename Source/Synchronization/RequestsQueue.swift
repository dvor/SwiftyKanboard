//
//  RequestsQueue.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import Foundation

protocol DownloadRequestsQueue {
    func add(downloadRequest: DownloadRequest, isConcurent: Bool)
}

protocol UploadRequestsQueue {
    func add(uploadRequest: UploadRequest)
}

protocol RequestsQueueDelegate: class {
    func requestsQueue(_ queue: RequestsQueue, requestsInProgressUpdate requestsInProgress: Bool)
}

class RequestsQueue: DownloadRequestsQueue, UploadRequestsQueue {
    private struct DownloadRequestContainer {
        let request: DownloadRequest
        let isConcurent: Bool
    }

    private(set) var requestsInProgress = false {
        didSet {
            if oldValue != requestsInProgress {
                delegate?.requestsQueue(self, requestsInProgressUpdate: requestsInProgress)
            }
        }
    }
    weak var delegate: RequestsQueueDelegate?

    private let networkService: NetworkService
    private let strategy: SynchronizationStrategy
    private let queue: DispatchQueue

    private var isRunning = false
    private var downloadQueue = [DownloadRequestContainer]()
    private var uploadQueue = [UploadRequest]()

    init(networkService: NetworkService, strategy: SynchronizationStrategy, queue: DispatchQueue) {
        self.networkService = networkService
        self.strategy = strategy
        self.queue = queue
    }

    /// Start queue if it was not started yet.
    func start() {
        if isRunning { return }
        isRunning = true

        performNextOperation()
    }

    func add(downloadRequest: DownloadRequest, isConcurent: Bool) {
        // FIXME Concurent requests are disabled due to bug in Kanboard
        // See https://github.com/kanboard/kanboard/issues/3879
        downloadQueue.append(DownloadRequestContainer(request: downloadRequest, isConcurent: false))
    }

    func add(uploadRequest: UploadRequest) {
        uploadQueue.append(uploadRequest)
    }
}

private extension RequestsQueue {
    func scheduleNextOperation() {
        queue.asyncAfter(deadline: .now() + strategy.idleDelay) { [weak self] in
            self?.performNextOperation()
        }
    }

    func performNextOperation() {
        let requests: [AbstractRequest]

        if let uploadRequests = nextUploadRequests() {
            requests = uploadRequests
        }
        else if let downloadRequests = nextDownloadRequests() {
            requests = downloadRequests
        }
        else {
            scheduleNextOperation()
            requestsInProgress = false
            return
        }

        requestsInProgress = true

        networkService.batch(requests, completion: { [weak self] in
            self?.scheduleNextOperation()
        },
        failure:{ [weak self] error in
            // TODO handle generic errors like user logout
            self?.scheduleNextOperation()
        })
    }

    func nextDownloadRequests() -> [DownloadRequest]? {
        if downloadQueue.isEmpty {
            return nil
        }

        var requests = [DownloadRequest]()

        for container in downloadQueue {
            if !container.isConcurent {
                if requests.isEmpty {
                    requests.append(container.request)
                }
                break
            }

            requests.append(container.request)
        }

        downloadQueue.removeFirst(requests.count)
        return requests
    }

    func nextUploadRequests() -> [UploadRequest]? {
        if uploadQueue.isEmpty {
            return nil
        }

        return [uploadQueue.removeFirst()]
    }
}
