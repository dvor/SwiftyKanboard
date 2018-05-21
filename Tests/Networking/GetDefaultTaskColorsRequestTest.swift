//
//  GetDefaultTaskColorsRequestTest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import XCTest

class GetDefaultTaskColorsRequestTest: XCTestCase {
    func testParsing() {
        let json = """
        {
            "yellow": {
                "name": "Yellow",
                "background": "rgb(245, 247, 196)",
                "border": "rgb(223, 227, 45)"
            },
            "amber": {
                "name": "Amber",
                "background": "#ffe082",
                "border": "#ffa000"
            }
        }
        """

        let expectation = XCTestExpectation(description: "Completion called")

        let request = GetDefaultTaskColorsRequest() { colors in
            XCTAssertEqual(colors.count, 2)

            let c0 = colors[0]
            XCTAssertEqual(c0.id, "amber")
            XCTAssertEqual(c0.name, "Amber")
            XCTAssertEqual(c0.backgroundRed, 1.0, accuracy: 0.001)
            XCTAssertEqual(c0.backgroundGreen, 0.8784, accuracy: 0.001)
            XCTAssertEqual(c0.backgroundBlue, 0.5098, accuracy: 0.001)
            XCTAssertEqual(c0.borderRed, 1.0, accuracy: 0.001)
            XCTAssertEqual(c0.borderGreen, 0.6274, accuracy: 0.001)
            XCTAssertEqual(c0.borderBlue, 0.0, accuracy: 0.001)

            let c1 = colors[1]
            XCTAssertEqual(c1.id, "yellow")
            XCTAssertEqual(c1.name, "Yellow")
            XCTAssertEqual(c1.backgroundRed, 0.9608, accuracy: 0.001)
            XCTAssertEqual(c1.backgroundGreen, 0.9686, accuracy: 0.001)
            XCTAssertEqual(c1.backgroundBlue, 0.7686, accuracy: 0.001)
            XCTAssertEqual(c1.borderRed, 0.8745, accuracy: 0.001)
            XCTAssertEqual(c1.borderGreen, 0.8902, accuracy: 0.001)
            XCTAssertEqual(c1.borderBlue, 0.1764, accuracy: 0.001)

            expectation.fulfill()
        }

        let jsonObject = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: [])

        try! request.parse(jsonObject)
        request.finish()

        wait(for: [expectation], timeout: 0.1)
    }
}
