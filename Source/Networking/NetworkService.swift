//
//  NetworkService.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

class NetworkService {
    private var idGenerator = IdGenerator()
    private let delegateQueue: DispatchQueue
    private let requestURL: URL
    private let session: URLSession

    /// Parameters:
    /// - delegateQueue: Callbacks will be asynchronously scheduled on this queue.
    init(delegateQueue: DispatchQueue) {
        self.delegateQueue = delegateQueue

        let keychain = KeychainManager()

        self.requestURL = URL(string: keychain.baseURL!)!.appendingPathComponent("jsonrpc.php")

        let loginString = "\(keychain.userName!):\(keychain.apiToken!)"
        let loginData = loginString.data(using: .utf8)!
        let base64 = loginData.base64EncodedString()

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [ "Authorization" : "Basic \(base64)" ]

        self.session = URLSession(configuration: configuration)
    }

    func createRequest<T: AbstractRequest>(_ type: T.Type, completion: T.Completion) -> T {
        return (T.self as T.Type).init(id: idGenerator.next(), completion: completion)
    }

    func batch(_ requests: [BaseRequest]) {
        log("Batch requests: \(requests)")

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try! JSONEncoder().encode(requests)

        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            let array = try! JSONSerialization.jsonObject(with: data!, options: []) as! [Dictionary<String, Any>]

            for dict in array {
                let id = dict["id"]! as! Int
                let result = dict["result"]!

                let request = requests.filter{ $0.id == id }.first!

                self?.delegateQueue.async {
                    request.process(result)
                }
            }
        }

        task.resume()
    }
}

extension NetworkService {
    struct IdGenerator {
        private var current = 1

        mutating func next() -> Int {
            defer {
                current += 1
            }

            return current
        }
    }
}

