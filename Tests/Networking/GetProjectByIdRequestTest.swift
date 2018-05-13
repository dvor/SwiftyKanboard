//
//  GetProjectByIdRequestTest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import XCTest

class GetProjectByIdRequestTest: XCTestCase {
    func testParsing() {
        let json = """
        {
            "id": "1",
            "name": "API test",
            "is_active": "1",
            "token": "",
            "last_modified": "1436119135",
            "is_public": "0",
            "is_private": "0",
            "default_swimlane": "Default swimlane",
            "show_default_swimlane": "1",
            "description": "test",
            "identifier": "",
            "url": {
                "board": "board.com",
                "calendar": "calendar.com",
                "list": "list.com"
            }
        }
        """

        let expectation = XCTestExpectation(description: "Completion called")

        let request = GetProjectByIdRequest(projectId: "1") { project in
            XCTAssertEqual(project.id, "1")
            XCTAssertEqual(project.name, "API test")
            XCTAssertEqual(project.description, "test")
            XCTAssertEqual(project.defaultSwimlane, "Default swimlane")
            XCTAssertEqual(project.showDefaultSwimlane, true)
            XCTAssertEqual(project.isActive, true)
            XCTAssertEqual(project.isPublic, false)
            XCTAssertEqual(project.isPrivate, false)
            XCTAssertEqual(project.boardURLString, "board.com")
            XCTAssertEqual(project.calendarURLString, "calendar.com")
            XCTAssertEqual(project.listURLString, "list.com")
            XCTAssertEqual(project.lastModified, Date(timeIntervalSince1970: 1436119135))

            expectation.fulfill()
        }

        let jsonObject = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: [])

        try! request.parse(jsonObject)
        request.finish()

        wait(for: [expectation], timeout: 0.1)
    }
}
