//
//  GetColumnsRequestTest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import XCTest
@testable import Kanboard

class GetColumnsRequestTest: XCTestCase {
    func testParsing() {
        let json = """
        [
            {
                "id": "1",
                "title": "Backlog",
                "position": "1",
                "project_id": "1",
                "task_limit": "0"
            },
            {
                "id": "2",
                "title": "Ready",
                "position": "2",
                "project_id": "1",
                "task_limit": "3"
            },
            {
                "id": "3",
                "title": "Work in progress",
                "position": "3",
                "project_id": "1",
                "task_limit": "0"
            }
        ]
        """

        let expectation = XCTestExpectation(description: "Completion called")

        let request = GetColumnsRequest(projectId: "1", completion: { columns in
            XCTAssertEqual(columns.count, 3)

            let c0 = columns[0]
            XCTAssertEqual(c0.id, "1")
            XCTAssertEqual(c0.title, "Backlog")
            XCTAssertEqual(c0.projectId, "1")
            XCTAssertEqual(c0.position, 1)
            XCTAssertEqual(c0.taskLimit, 0)

            let c1 = columns[1]
            XCTAssertEqual(c1.id, "2")
            XCTAssertEqual(c1.title, "Ready")
            XCTAssertEqual(c1.projectId, "1")
            XCTAssertEqual(c1.position, 2)
            XCTAssertEqual(c1.taskLimit, 3)

            let c2 = columns[2]
            XCTAssertEqual(c2.id, "3")
            XCTAssertEqual(c2.title, "Work in progress")
            XCTAssertEqual(c2.projectId, "1")
            XCTAssertEqual(c2.position, 3)
            XCTAssertEqual(c2.taskLimit, 0)

            expectation.fulfill()
        }, failure: { _ in })

        let jsonObject = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: [])

        try! request.parse(jsonObject)
        request.finish()

        wait(for: [expectation], timeout: 0.1)
    }
}
