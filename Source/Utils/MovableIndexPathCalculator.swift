//
//  MovableIndexPathCalculator.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 24/06/2018.
//

import Foundation

class MovableIndexPathCalculator {
    static func originalIndexPath(from indexPath: IndexPath,
                                  movingItemOriginalIndexPath originalIndexPath: IndexPath,
                                  movingItemCurrentIndexPath currentIndexPath: IndexPath) -> IndexPath {
        if indexPath == currentIndexPath {
            return originalIndexPath
        }

        var result = indexPath

        if result.section == currentIndexPath.section && result.row >= currentIndexPath.row {
            result.row -= 1
        }
        if result.section == originalIndexPath.section && result.row >= originalIndexPath.row {
            result.row += 1
        }

        return result
    }
}
