//
//  GetDefaultTaskColorsRequest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import Foundation

class GetDefaultTaskColorsRequest: DownloadRequest {
    let id = RequestIdFactory.next()
    let method = "getDefaultTaskColors"
    let parameters: [String:String]? = nil

    private let completion: ([RemoteTaskColor]) -> Void
    private var response: [RemoteTaskColor]?

    required init(completion: @escaping ([RemoteTaskColor]) -> Void) {
        self.completion = completion
    }

    func parse(_ result: Any) throws {
        let dict = try DictionaryDecoder(result)
        var response = [RemoteTaskColor]()

        for (id, value) in dict {
            let color = try RemoteTaskColor(id: id, value: value)
            response.append(color)
        }
        self.response = response
    }

    func finish() {
        completion(response!)
    }
}
