//
//  NetworkService.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Foundation

class NetworkService {
    private var idGenerator = IdGenerator()

    func createRequest<T: AbstractRequest>(_ type: T.Type, completion: T.Completion) -> T {
        return (T.self as T.Type).init(id: idGenerator.next(), completion: completion)
    }

    func batch(_ requests: [BaseRequest]) {
        let loginData = "\(Constants.user):\(Constants.token)".data(using: .utf8)!
        let base64 = loginData.base64EncodedString()

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization" : "Basic \(base64)"
        ]

        let url = Constants.baseURL.appendingPathComponent("jsonrpc.php")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try! JSONEncoder().encode(requests)

        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            let array = try! JSONSerialization.jsonObject(with: data!, options: []) as! [Dictionary<String, Any>]

            for dict in array {
                let id = dict["id"]! as! Int
                let result = dict["result"]!

                let request = requests.filter{ $0.id == id }.first!
                request.process(result)
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

