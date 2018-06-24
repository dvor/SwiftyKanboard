//
//  SyncAnimatedButton.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 24/06/2018.
//

import UIKit
import SnapKit

private struct Constants {
    static let animationDuration = 1.5
}

class SyncAnimatedButton: UIButton {
    private var syncImageView: UIImageView!
    private var animator: UIViewPropertyAnimator?

    var isAnimating = false {
        didSet {
            if isAnimating {
                startNextAnimation()
            }
        }
    }

    init() {
        super.init(frame: CGRect())
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SyncAnimatedButton {
    func setup() {
        syncImageView = UIImageView(image: UIImage(named: "sync-arrows")!.withRenderingMode(.alwaysTemplate))
        syncImageView.contentMode = .center
        syncImageView.tintColor = UIButton.appearance().tintColor
        addSubview(syncImageView)

        syncImageView.snp.makeConstraints {
            $0.center.equalTo(self)
        }
    }

    func startNextAnimation() {
        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Constants.animationDuration,
                                                                  delay: 0.0,
                                                                  options: .curveLinear,
                                                                  animations: { [weak self] in
            guard let `self` = self else { return }
            self.syncImageView?.transform = self.syncImageView.transform.rotated(by: CGFloat.pi)
        }, completion: { [weak self] _ in
            guard let `self` = self else { return }
            if self.isAnimating {
                self.startNextAnimation()
            }
        })
    }
}
