//
//  GetAllProjectsRequestTest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import XCTest

class GetAllProjectsRequestTest: XCTestCase {
    func testParsing() {
        let json = """
        [
            {
                "id": "1",
                "name": "API test",
                "is_active": "1",
                "token": "",
                "last_modified": "1436119570",
                "is_public": "0",
                "is_private": "0",
                "default_swimlane": "Default swimlane",
                "show_default_swimlane": "1",
                "description": "Some random description",
                "identifier": "",
                "url": {
                    "board": "board.com",
                    "calendar": "calendar.com",
                    "list": "list.com"
                }
            },
            {
                "id": "2",
                "name": "Null project",
                "is_active": "0",
                "token": "",
                "last_modified": "1536119570",
                "is_public": "1",
                "is_private": "1",
                "default_swimlane": "Another swimlane",
                "show_default_swimlane": "0",
                "description": null,
                "identifier": "",
                "url": {
                    "board": null,
                    "calendar": null,
                    "list": null
                }
            }
        ]
        """

        let expectation = XCTestExpectation(description: "Completion called")

        let request = GetAllProjectsRequest() { requests in
            XCTAssertEqual(requests.count, 2)

            let r0 = requests[0]
            XCTAssertEqual(r0.id, "1")
            XCTAssertEqual(r0.name, "API test")
            XCTAssertEqual(r0.description, "Some random description")
            XCTAssertEqual(r0.defaultSwimlane, "Default swimlane")
            XCTAssertEqual(r0.showDefaultSwimlane, true)
            XCTAssertEqual(r0.isActive, true)
            XCTAssertEqual(r0.isPublic, false)
            XCTAssertEqual(r0.isPrivate, false)
            XCTAssertEqual(r0.boardURLString, "board.com")
            XCTAssertEqual(r0.calendarURLString, "calendar.com")
            XCTAssertEqual(r0.listURLString, "list.com")
            XCTAssertEqual(r0.lastModified, Date(timeIntervalSince1970: 1436119570))

            let r1 = requests[1]
            XCTAssertEqual(r1.id, "2")
            XCTAssertEqual(r1.name, "Null project")
            XCTAssertEqual(r1.description, nil)
            XCTAssertEqual(r1.defaultSwimlane, "Another swimlane")
            XCTAssertEqual(r1.showDefaultSwimlane, false)
            XCTAssertEqual(r1.isActive, false)
            XCTAssertEqual(r1.isPublic, true)
            XCTAssertEqual(r1.isPrivate, true)
            XCTAssertEqual(r1.boardURLString, nil)
            XCTAssertEqual(r1.calendarURLString, nil)
            XCTAssertEqual(r1.listURLString, nil)
            XCTAssertEqual(r1.lastModified, Date(timeIntervalSince1970: 1536119570))

            expectation.fulfill()
        }

        let jsonObject = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: [])

        try! request.parse(jsonObject)
        request.finish()

        wait(for: [expectation], timeout: 0.1)
    }
}
