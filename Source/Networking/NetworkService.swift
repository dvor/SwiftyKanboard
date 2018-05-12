//
//  NetworkService.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

enum NetworkServiceError: Error {
    case noDataReturned
    case wrongJsonFormat
}

class NetworkService {
    private let delegateQueue: DispatchQueue
    private let requestURL: URL
    private let session: URLSession

    /// Parameters:
    /// - delegateQueue: Callbacks will be asynchronously scheduled on this queue.
    init(baseURL: URL, userName: String, apiToken: String, delegateQueue: DispatchQueue) {
        self.requestURL = baseURL.appendingPathComponent("jsonrpc.php")
        self.delegateQueue = delegateQueue

        let configuration = URLSessionConfiguration.default

        if let base64 = "\(userName):\(apiToken)".data(using: .utf8)?.base64EncodedString() {
            configuration.httpAdditionalHeaders = [ "Authorization" : "Basic \(base64)" ]
        }

        self.session = URLSession(configuration: configuration)
    }

    func batch(_ requests: [AbstractRequest], completion: (() -> Void)?, failure: ((Error) -> Void)?) {
        log("Batch requests: \(requests)")

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "POST"

        do {
            urlRequest.httpBody = try JSONEncoder().encode(requests)
        }
        catch let error {
            safeFailure(failure, error)
            return
        }

        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            log("Batch response: statusCode \(String(describing: statusCode)), error \(String(describing: error))")

            self?.processData(data,
                              response: response,
                              error: error,
                              for: requests,
                              completion: completion,
                              failure: failure)
        }

        task.resume()
    }
}

private extension NetworkService {
    func safeFailure(_ failure: ((Error) -> Void)?, _ error: Error) {
        delegateQueue.async {
            failure?(error)
        }
    }

    func processData(_ data: Data?,
                     response: URLResponse?,
                     error: Error?,
                     for requests: [AbstractRequest],
                     completion: (() -> Void)?,
                     failure: ((Error) -> Void)?) {
        if let error = error {
            safeFailure(failure, error)
            return
        }

        guard let data = data else {
            safeFailure(failure, NetworkServiceError.noDataReturned)
            return
        }

        let jsonObject: Any
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        }
        catch let error {
            safeFailure(failure, error)
            return
        }

        if !parse(jsonObject: jsonObject, for: requests) {
            safeFailure(failure, NetworkServiceError.wrongJsonFormat)
            return
        }

        delegateQueue.async {
            requests.forEach { $0.finish() }
            completion?()
        }
    }

    func parse(jsonObject: Any, for requests: [AbstractRequest]) -> Bool {
        guard let array = jsonObject as? [Dictionary<String, Any>] else {
            return false
        }

        for dict in array {
            guard let id = dict["id"] as? Int,
            let result = dict["result"],
            let request = requests.filter({ $0.id == id }).first
            else {
                return false
            }

            if !request.parse(result) {
                return false
            }
        }

        return true
    }
}
