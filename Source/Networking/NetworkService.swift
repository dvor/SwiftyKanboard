//
//  NetworkService.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

enum NetworkServiceError: Error {
    case cannotEncodeJson(Error)
    case networkError(Error)
    case noDataReturned
    case cannotParseJson(Error)
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

    func batch(_ requests: [AbstractRequest], completion: (() -> Void)?, failure: ((NetworkServiceError) -> Void)?) {
        log.infoMessage("Batch requests: \(requests)")

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "POST"

        do {
            urlRequest.httpBody = try JSONRPCEncoder.encodeRPCRequests(requests)
        }
        catch let error {
            globalFail(requests: requests, failureBlock: failure, with: .cannotEncodeJson(error))
            return
        }

        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            log.infoMessage("Batch response: statusCode \(String(describing: statusCode)), error \(String(describing: error))")

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
    func globalFail(requests: [AbstractRequest], failureBlock: ((NetworkServiceError) -> Void)?, with error: NetworkServiceError) {
        delegateQueue.async {
            for request in requests {
                request.failure(error)
            }

            failureBlock?(error)
        }
    }

    func processData(_ data: Data?,
                     response: URLResponse?,
                     error: Error?,
                     for requests: [AbstractRequest],
                     completion: (() -> Void)?,
                     failure: ((NetworkServiceError) -> Void)?) {
        if let error = error {
            globalFail(requests: requests, failureBlock: failure, with: .networkError(error))
            return
        }

        guard let data = data else {
            globalFail(requests: requests, failureBlock: failure, with: .noDataReturned)
            return
        }

        var responses = [Int:DictionaryDecoder]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let array = try ArrayDecoder<Any>(jsonObject)

            for object in array {
                let dict = try DictionaryDecoder(object)
                let id: Int = try dict.value(forKey: "id")

                responses[id] = dict
            }
        }
        catch let error {
            globalFail(requests: requests, failureBlock: failure, with: .cannotParseJson(error))
            return
        }

        parse(responses: responses, for: requests)

        delegateQueue.async {
            completion?()
        }
    }

    func parse(responses: [Int:DictionaryDecoder], for requests: [AbstractRequest]) {
        for (id, dict) in responses {
            guard let request = requests.filter({ $0.id == id }).first else {
                continue
            }

            do {
                let result: Any = try dict.value(forKey: "result")
                try request.parse(result)

                delegateQueue.async {
                    request.finish()
                }
            }
            catch let error {
                delegateQueue.async {
                    request.failure(.cannotParseJson(error))
                }
            }
        }
    }
}
