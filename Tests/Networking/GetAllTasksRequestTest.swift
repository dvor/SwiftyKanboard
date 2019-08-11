//
//  GetAllTasksRequestTest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import XCTest
@testable import Kanboard

class GetAllTasksRequestTest: XCTestCase {
    func testParsing() {
        let json = """
        [
            {
                "id": "1",
                "title": "Task #1",
                "description": "Some description",
                "date_creation": "1409961789",
                "color_id": "blue",
                "project_id": "1",
                "column_id": "2",
                "owner_id": "1",
                "position": "1",
                "is_active": "1",
                "date_completed": null,
                "score": "0",
                "date_due": "0",
                "category_id": "0",
                "creator_id": "0",
                "date_modification": "1409961789",
                "reference": "",
                "date_started": null,
                "time_spent": "0",
                "time_estimated": "0",
                "swimlane_id": "0",
                "date_moved": "1430783191",
                "recurrence_status": "0",
                "recurrence_trigger": "0",
                "recurrence_factor": "0",
                "recurrence_timeframe": "0",
                "recurrence_basedate": "0",
                "recurrence_parent": null,
                "recurrence_child": null,
                "priority": "0",
                "external_provider": null,
                "external_uri": null,
                "url": "http://127.0.0.1:8000/?controller=task&action=show&task_id=1&project_id=1",
                "color": {
                    "name": "Blue",
                    "background": "rgb(219, 235, 255)",
                    "border": "rgb(168, 207, 255)"
                }
            },
            {
                "id": "2",
                "title": "Test",
                "description": null,
                "date_creation": "1409962115",
                "color_id": "green",
                "project_id": "11",
                "column_id": "12",
                "owner_id": "13",
                "position": "14",
                "is_active": "0",
                "date_completed": "1409962117",
                "score": "16",
                "date_due": "1409962120",
                "category_id": "18",
                "creator_id": "19",
                "date_modification": "1409962115",
                "reference": "",
                "date_started": "1409962117",
                "time_spent": "20",
                "time_estimated": "21",
                "swimlane_id": "22",
                "date_moved": "1430783193",
                "recurrence_status": "23",
                "recurrence_trigger": "24",
                "recurrence_factor": "25",
                "recurrence_timeframe": "26",
                "recurrence_basedate": "27",
                "recurrence_parent": null,
                "recurrence_child": null,
                "priority": "28",
                "external_provider": null,
                "external_uri": null,
                "url": "http://127.0.0.1:8000/?controller=task&action=show&task_id=2&project_id=1",
                "color": {
                    "name": "Green",
                    "background": "rgb(189, 244, 203)",
                    "border": "rgb(74, 227, 113)"
                }
            }
        ]
        """

        let expectation = XCTestExpectation(description: "Completion called")

        let request = GetAllTasksRequest(projectId: "1", active: true, completion: { tasks in
            XCTAssertEqual(tasks.count, 2)

            let t0 = tasks[0]
            XCTAssertEqual(t0.id, "1")
            XCTAssertEqual(t0.title, "Task #1")
            XCTAssertEqual(t0.description, "Some description")
            XCTAssertEqual(t0.urlString, "http://127.0.0.1:8000/?controller=task&action=show&task_id=1&project_id=1")

            XCTAssertEqual(t0.isActive, true)
            XCTAssertEqual(t0.position, 1)
            XCTAssertEqual(t0.score, 0)
            XCTAssertEqual(t0.priority, 0)

            XCTAssertEqual(t0.colorId, "blue")
            XCTAssertEqual(t0.projectId, "1")
            XCTAssertEqual(t0.columnId, "2")
            XCTAssertEqual(t0.ownerId, "1")
            XCTAssertEqual(t0.creatorId, "0")
            XCTAssertEqual(t0.categoryId, "0")
            XCTAssertEqual(t0.swimlaneId, "0")

            XCTAssertEqual(t0.creationDate, Date(timeIntervalSince1970: 1409961789))
            XCTAssertEqual(t0.startedDate, nil)
            XCTAssertEqual(t0.dueDate, nil)
            XCTAssertEqual(t0.modificationDate, Date(timeIntervalSince1970: 1409961789))
            XCTAssertEqual(t0.movedDate, Date(timeIntervalSince1970: 1430783191))
            XCTAssertEqual(t0.completedDate, nil)

            let t1 = tasks[1]
            XCTAssertEqual(t1.id, "2")
            XCTAssertEqual(t1.title, "Test")
            XCTAssertEqual(t1.description, nil)
            XCTAssertEqual(t1.urlString, "http://127.0.0.1:8000/?controller=task&action=show&task_id=2&project_id=1")

            XCTAssertEqual(t1.isActive, false)
            XCTAssertEqual(t1.position, 14)
            XCTAssertEqual(t1.score, 16)
            XCTAssertEqual(t1.priority, 28)

            XCTAssertEqual(t1.colorId, "green")
            XCTAssertEqual(t1.projectId, "11")
            XCTAssertEqual(t1.columnId, "12")
            XCTAssertEqual(t1.ownerId, "13")
            XCTAssertEqual(t1.creatorId, "19")
            XCTAssertEqual(t1.categoryId, "18")
            XCTAssertEqual(t1.swimlaneId, "22")

            XCTAssertEqual(t1.creationDate, Date(timeIntervalSince1970: 1409962115))
            XCTAssertEqual(t1.startedDate, Date(timeIntervalSince1970: 1409962117))
            XCTAssertEqual(t1.dueDate, Date(timeIntervalSince1970: 1409962120))
            XCTAssertEqual(t1.modificationDate, Date(timeIntervalSince1970: 1409962115))
            XCTAssertEqual(t1.movedDate, Date(timeIntervalSince1970: 1430783193))
            XCTAssertEqual(t1.completedDate, Date(timeIntervalSince1970: 1409962117))

            expectation.fulfill()
        }, failure: { _ in })

        let jsonObject = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: [])

        try! request.parse(jsonObject)
        request.finish()

        wait(for: [expectation], timeout: 0.1)
    }
}
