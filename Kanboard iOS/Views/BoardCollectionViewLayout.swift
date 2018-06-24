//
//  BoardCollectionViewLayout.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/06/2018.
//

import UIKit

private struct Constants {
    static let verticalOffset: CGFloat = 5.0
    static let horizontalOffset: CGFloat = 5.0
}

protocol BoardCollectionViewLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemAt indexPath: IndexPath,
                        forWidth width: CGFloat) -> CGFloat
}

class BoardCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: BoardCollectionViewLayoutDelegate!

    private let horizontalOffsetFromEdge: CGFloat

    private var contentSize = CGSize()
    private var attributes = [[UICollectionViewLayoutAttributes]]()

    private var movingItemOriginalIndexPath: IndexPath?
    private var movingItemCurrentIndexPath: IndexPath?

    // This property is changed by user of layout.
    var isMovingItem = false {
        didSet {
            if !isMovingItem {
                movingItemOriginalIndexPath = nil
                movingItemCurrentIndexPath = nil
            }
        }
    }

    var visibleColumn: Int {
        get {
            guard let collectionView = collectionView else { return 0 }
            return columnIndexForOffsetX(collectionView.contentOffset.x)
        }
    }

    func setVisibleColumn(_ column: Int, animated: Bool) {
        guard let collectionView = collectionView else { return }

        var realColumn = column
        if realColumn < 0 {
            realColumn = 0
        }
        if realColumn > attributes.count - 1 {
            realColumn = attributes.count - 1
        }

        var offset = collectionView.contentOffset
        offset.x = offsetXForColumn(realColumn)
        collectionView.setContentOffset(offset, animated: animated)
    }

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

        let screenMinimalSide = self.screenMinimalSide
        let pageWidth = self.pageWidth
        var currentOrigin = CGPoint()

        for section in 0..<collectionView.numberOfSections {
            attributes.append([UICollectionViewLayoutAttributes]())
            currentOrigin.y = 0

            for row in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                let dataSourceIndexPath = self.dataSourceIndexPath(for: row, in: section)

                let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)

                let x = currentOrigin.x + Constants.horizontalOffset
                let y = currentOrigin.y + Constants.verticalOffset
                let width = pageWidth
                let height = delegate.collectionView(collectionView, heightForItemAt: dataSourceIndexPath, forWidth: width)

                attr.frame = CGRect(x: x, y: y, width: width, height: height)
                attributes[section].append(attr)

                currentOrigin.y += height + 2 * Constants.verticalOffset
                contentSize.height = max(contentSize.height, currentOrigin.y)
            }

            currentOrigin.x += screenMinimalSide - 2 * horizontalOffsetFromEdge
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
        var column = columnIndexForOffsetX(proposedContentOffset.x)

        if column == visibleColumn {
            if velocity.x > 0 && column < (attributes.count - 1) {
                column += 1
            }
            else if velocity.x < 0 && column > 0 {
                column -= 1
            }
        }

        return CGPoint(x: offsetXForColumn(column), y: proposedContentOffset.y)
    }

    override func targetIndexPath(forInteractivelyMovingItem previousIndexPath: IndexPath, withPosition position: CGPoint) -> IndexPath {
        let targetPath = super.targetIndexPath(forInteractivelyMovingItem: previousIndexPath, withPosition: position)

        if movingItemOriginalIndexPath == nil {
            // This is first call of this method for this movement. Let's save original index path.
            movingItemOriginalIndexPath = previousIndexPath
        }
        movingItemCurrentIndexPath = targetPath

        return targetPath
    }
}

private extension BoardCollectionViewLayout {
    var screenMinimalSide: CGFloat {
        get {
            return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        }
    }

    var pageWidth: CGFloat {
        get {
            return screenMinimalSide - 2 * Constants.horizontalOffset - 2 * horizontalOffsetFromEdge
        }
    }

    func columnIndexForOffsetX(_ offsetX: CGFloat) -> Int {
        let centerX = offsetX + screenMinimalSide / 2
        let pageWidth = self.pageWidth
        var x = -horizontalOffsetFromEdge

        for column in 0..<attributes.count {
            x += pageWidth + Constants.horizontalOffset

            if centerX < x {
                return column
            }
        }

        return attributes.count - 1
    }

    func offsetXForColumn(_ column: Int) -> CGFloat {
        return -horizontalOffsetFromEdge + CGFloat(column) * (pageWidth + 2 * Constants.horizontalOffset)
    }

    // When moving item UICollectionView temporarely updates it's row/sections without notifying dataSource.
    // When calculating layout we still want to use correct data from dataSource.
    //
    // In this method we convert UICollectionView's indexPath to one in the dataSource.
    func dataSourceIndexPath(for row: Int, in section: Int) -> IndexPath {
        let indexPath = IndexPath(row: row, section: section)

        guard isMovingItem,
              let originalIndexPath = movingItemOriginalIndexPath,
              let currentIndexPath = movingItemCurrentIndexPath else {
            // Not moving item, indexPaths are same.
            return indexPath
        }

        return MovableIndexPathCalculator.originalIndexPath(from: indexPath,
                                                            movingItemOriginalIndexPath: originalIndexPath,
                                                            movingItemCurrentIndexPath: currentIndexPath)
    }
}
