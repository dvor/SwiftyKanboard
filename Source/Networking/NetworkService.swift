//
//  NetworkService.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

enum NetworkServiceError: Error {
    case noDataReturned
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
            urlRequest.httpBody = try JSONRPCEncoder.encodeRPCRequests(requests)
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
            try parse(jsonObject: jsonObject, for: requests)
        }
        catch let error {
            safeFailure(failure, error)
            return
        }

        delegateQueue.async {
            requests.forEach { $0.finish() }
            completion?()
        }
    }

    func parse(jsonObject: Any, for requests: [AbstractRequest]) throws {
        let array = try ArrayDecoder<Any>(jsonObject)

        for object in array {
            let dict = try DictionaryDecoder(object)

            let id: Int = try dict.value(forKey: "id")
            let result: Any = try dict.value(forKey: "result")
            guard let request = requests.filter({ $0.id == id }).first else {
                throw DecoderError.badType
            }

            try request.parse(result)
        }
    }
}
