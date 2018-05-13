//
//  BoardCollectionViewLayout.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 15/05/2018.
//

import Cocoa

private struct Constants {
    static let minimumSize = CGSize(width: 150, height: 80)
    static let indentation = CGSize(width: 10, height: 10)
}

class BoardCollectionViewLayout: NSCollectionViewLayout {
    private var attributes = [[NSCollectionViewLayoutAttributes]]()
    private var contentSize = NSSize()

    override var collectionViewContentSize: NSSize {
        get {
            return contentSize
        }
    }

    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }

        attributes = [[NSCollectionViewLayoutAttributes]]()
        contentSize = NSSize()
        var origin = CGPoint(x: 0, y: 0)
        let width = sectionWidth(for: collectionView)

        for section in 0..<collectionView.numberOfSections {
            var sectionAttributes = [NSCollectionViewLayoutAttributes]()

            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)

                let attr = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
                attr.frame = NSRect(x: origin.x, y: origin.y, width: width, height: Constants.minimumSize.height)

                sectionAttributes.append(attr)
                origin.y += Constants.minimumSize.height + Constants.indentation.height
            }

            attributes.append(sectionAttributes)

            contentSize.height = max(contentSize.height, origin.y)
            origin.x += width + Constants.indentation.width
            origin.y = 0
        }

        contentSize.width = origin.x
    }

    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        var results = [NSCollectionViewLayoutAttributes]()

        for section in attributes {
            for item in section {
                if rect.intersects(item.frame) {
                    results.append(item)
                }
            }
        }

        return results
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return attributes[indexPath.section][indexPath.item]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return true
    }
}

private extension BoardCollectionViewLayout {
    func sectionWidth(for collectionView: NSCollectionView) -> CGFloat {
        let numberOfSections = collectionView.numberOfSections

        guard numberOfSections > 0 else {
            return 0
        }

        let all = collectionView.bounds.width - CGFloat(numberOfSections - 1) * Constants.indentation.width

        return max(
            all / CGFloat(numberOfSections),
            Constants.minimumSize.width
        )
    }
}
