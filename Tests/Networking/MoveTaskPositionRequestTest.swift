//
//  MoveTaskPositionRequestTest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/06/2018.
//

import XCTest
@testable import Kanboard

class MoveTaskPositionRequestTest: XCTestCase {
    func testTrue() {
        let json = true

        let expectation = XCTestExpectation(description: "Completion called")

        let request = MoveTaskPositionRequest(projectId: "1",
                                              taskId: "2",
                                              columnId: "3",
                                              position: 4,
                                              swimlaneId: "5",
                                              completion: { result in
            XCTAssertTrue(result)

            expectation.fulfill()
        }, failure: { _ in })


        try! request.parse(json)
        request.finish()

        wait(for: [expectation], timeout: 0.1)
    }

    func testFalse() {
        let json = false

        let expectation = XCTestExpectation(description: "Completion called")

        let request = MoveTaskPositionRequest(projectId: "1",
                                              taskId: "2",
                                              columnId: "3",
                                              position: 4,
                                              swimlaneId: "5",
                                              completion: { result in
            XCTAssertFalse(result)

            expectation.fulfill()
        }, failure: { _ in })


        try! request.parse(json)
        request.finish()

        wait(for: [expectation], timeout: 0.1)
    }
}
