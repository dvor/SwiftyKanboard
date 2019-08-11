//
//  MovableIndexPathCalculatorTest.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 24/06/2018.
//

import XCTest
@testable import Kanboard

class MovableIndexPathCalculatorTest: XCTestCase {
    func testNoMovement() {
        var indexPath: IndexPath
        var result: IndexPath
        var movingOriginal: IndexPath
        var movingCurrent: IndexPath

        movingOriginal = IndexPath(row: 2, section: 1)
        movingCurrent  = IndexPath(row: 2, section: 1)

        indexPath = IndexPath(row: 1, section: 1)
        result    = IndexPath(row: 1, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 2, section: 1)
        result    = IndexPath(row: 2, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 3, section: 1)
        result    = IndexPath(row: 3, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))
    }

    func testMovingToSameSectionDown() {
        var indexPath: IndexPath
        var result: IndexPath
        var movingOriginal: IndexPath
        var movingCurrent: IndexPath

        movingOriginal = IndexPath(row: 2, section: 1)
        movingCurrent  = IndexPath(row: 4, section: 1)

        indexPath = IndexPath(row: 1, section: 1)
        result    = IndexPath(row: 1, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 2, section: 1)
        result    = IndexPath(row: 3, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 3, section: 1)
        result    = IndexPath(row: 4, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 4, section: 1)
        result    = IndexPath(row: 2, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 5, section: 1)
        result    = IndexPath(row: 5, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))
    }

    func testMovingToSameSectionUp() {
        var indexPath: IndexPath
        var result: IndexPath
        var movingOriginal: IndexPath
        var movingCurrent: IndexPath

        movingOriginal = IndexPath(row: 4, section: 1)
        movingCurrent  = IndexPath(row: 2, section: 1)

        indexPath = IndexPath(row: 1, section: 1)
        result    = IndexPath(row: 1, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 2, section: 1)
        result    = IndexPath(row: 4, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 3, section: 1)
        result    = IndexPath(row: 2, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 4, section: 1)
        result    = IndexPath(row: 3, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 5, section: 1)
        result    = IndexPath(row: 5, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))
    }

    func testMovingToAnotherSection() {
        var indexPath: IndexPath
        var result: IndexPath
        var movingOriginal: IndexPath
        var movingCurrent: IndexPath

        movingOriginal = IndexPath(row: 2, section: 1)
        movingCurrent  = IndexPath(row: 5, section: 2)

        indexPath = IndexPath(row: 1, section: 1)
        result    = IndexPath(row: 1, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 2, section: 1)
        result    = IndexPath(row: 3, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 3, section: 1)
        result    = IndexPath(row: 4, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 2, section: 2)
        result    = IndexPath(row: 2, section: 2)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 4, section: 2)
        result    = IndexPath(row: 4, section: 2)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 5, section: 2)
        result    = IndexPath(row: 2, section: 1)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 6, section: 2)
        result    = IndexPath(row: 5, section: 2)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))

        indexPath = IndexPath(row: 8, section: 2)
        result    = IndexPath(row: 7, section: 2)

        XCTAssertEqual(result, MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                                            movingItemOriginalIndexPath: movingOriginal,
                                                                            movingItemCurrentIndexPath: movingCurrent))
    }
}
