//
//  GetVersionRequestTest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import XCTest
@testable import Kanboard

class GetVersionRequestTest: XCTestCase {
    func testParsing() {
        let json = "1.0.13"

        let expectation = XCTestExpectation(description: "Completion called")

        let request = GetVersionRequest(completion: { version in
            XCTAssertEqual(version, "1.0.13")

            expectation.fulfill()
        }, failure: { _ in })

        try! request.parse(json)
        request.finish()

        wait(for: [expectation], timeout: 0.1)
    }
}
