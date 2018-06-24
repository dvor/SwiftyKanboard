//
//  BoardCollectionViewCell.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/06/2018.
//

import UIKit
import SnapKit

private struct Constants {
    static let minimalHeight = 100.0
    static let offset = 5.0
}

class BoardCollectionViewCell: UICollectionViewCell {
    static let identifier = "BoardCollectionViewItem"
    var idLabel: UILabel!
    var titleLabel: UILabel!
    var priorityLabel: UILabel!

    override var backgroundColor: UIColor? {
        set {
            contentView.backgroundColor = newValue
        }
        get {
            return contentView.backgroundColor
        }
    }

    var borderColor: UIColor? {
        set {
            contentView.layer.borderColor = newValue?.cgColor
        }
        get {
            guard let cgColor = contentView.layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.borderWidth = 2.0
        contentView.layer.cornerRadius = 6.0
        createSubviews()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BoardCollectionViewCell {
    func createSubviews() {
        idLabel = UILabel()
        idLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        contentView.addSubview(idLabel)

        titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.numberOfLines = 3
        contentView.addSubview(titleLabel)

        priorityLabel = UILabel()
        priorityLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        priorityLabel.textColor = .lightGray
        contentView.addSubview(priorityLabel)
    }

    func makeConstraints() {
        idLabel.snp.makeConstraints {
            $0.top.equalTo(Constants.offset)
            $0.left.equalTo(contentView).offset(Constants.offset)
            $0.right.equalTo(contentView).offset(-Constants.offset)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(Constants.offset)
            $0.left.right.equalTo(idLabel)
        }

        priorityLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.offset)
            $0.right.equalTo(contentView).offset(-Constants.offset)
            $0.bottom.equalTo(contentView).offset(-Constants.offset)
        }
    }
}
