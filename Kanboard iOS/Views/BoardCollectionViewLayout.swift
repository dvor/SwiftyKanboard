//
//  BoardCollectionViewLayout.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/06/2018.
//

import UIKit

private struct Constants {
    static let minimalCellHeight: CGFloat = 100.0

    static let verticalOffset: CGFloat = 5.0
    static let horizontalOffset: CGFloat = 5.0
}

class BoardCollectionViewLayout: UICollectionViewLayout {
    private let horizontalOffsetFromEdge: CGFloat

    private var contentSize = CGSize()
    private var attributes = [[UICollectionViewLayoutAttributes]]()

    init(horizontalOffsetFromEdge: CGFloat) {
        self.horizontalOffsetFromEdge = horizontalOffsetFromEdge
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        attributes = [[UICollectionViewLayoutAttributes]]()
        contentSize = CGSize()

        guard let collectionView = collectionView else { return }

        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        var currentOrigin = CGPoint()

        for section in 0..<collectionView.numberOfSections {
            attributes.append([UICollectionViewLayoutAttributes]())
            currentOrigin.y = 0

            for row in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)

                let x = currentOrigin.x + Constants.horizontalOffset
                let y = currentOrigin.y + Constants.verticalOffset
                let width = screenWidth - 2 * Constants.horizontalOffset - 2 * horizontalOffsetFromEdge
                let height = Constants.minimalCellHeight

                attr.frame = CGRect(x: x, y: y, width: width, height: height)
                attributes[section].append(attr)

                currentOrigin.y += height + 2 * Constants.verticalOffset
                contentSize.height = max(contentSize.height, currentOrigin.y)
            }

            currentOrigin.x += screenWidth - 2 * horizontalOffsetFromEdge
            contentSize.width = max(contentSize.width, currentOrigin.x)
        }
    }

    override var collectionViewContentSize: CGSize {
        get {
            return contentSize
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var results = [UICollectionViewLayoutAttributes]()

        for section in attributes {
            for attr in section {
                if rect.intersects(attr.frame) {
                    results.append(attr)
                }
            }
        }

        return results
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.section][indexPath.row]
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }

        let proposedCenterX = proposedContentOffset.x + collectionView.bounds.size.width/2
        let proposedRect = CGRect(origin: CGPoint(x: proposedContentOffset.x, y: collectionView.contentOffset.y),
                                  size: collectionView.bounds.size)

        guard let attributes = layoutAttributesForElements(in: proposedRect),
              let closest = findClosestCell(to: proposedCenterX, in: attributes) else {
            return proposedContentOffset
        }

        return CGPoint(x: closest.center.x - collectionView.bounds.size.width / 2,
                       y: proposedContentOffset.y)
    }


    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

private extension BoardCollectionViewLayout {
    func findClosestCell(to xCoordinate: CGFloat, in attributes: [UICollectionViewLayoutAttributes]) -> UICollectionViewLayoutAttributes? {
        var selected: UICollectionViewLayoutAttributes? = nil

        for current in attributes {
            guard current.representedElementCategory == .cell else { continue }
            guard let previous = selected else {
                selected = current
                continue
            }

            if abs(current.center.x - xCoordinate) < abs(previous.center.x - xCoordinate) {
                selected = current
            }
        }

        return selected
    }
}
