//
//  BoardCollectionViewCell.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/06/2018.
//

import UIKit
import SnapKit

class BoardCollectionViewCell: UICollectionViewCell {
    static let identifier = "BoardCollectionViewItem"
    var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        createSubviews()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BoardCollectionViewCell {
    func createSubviews() {
        label = UILabel()
        contentView.addSubview(label)
    }

    func makeConstraints() {
        label.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
    }
}
