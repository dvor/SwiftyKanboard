//
//  ProgressHUD.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 03/06/2018.
//

import UIKit
// import JGProgressHUD

class ProgressHUD {
    enum HUDType {
        case loading
    }

    // private let hud: JGProgressHUD

    init(type: HUDType) {
        // hud = JGProgressHUD(style: .dark)

        // switch type {
        // case .loading:
        //     hud.textLabel.text = String(localized: "loading_indicator_text")
        // }
    }

    func show(in view: UIView) -> ProgressHUD {
        // hud.show(in: view)
        return self
    }

    func dismiss() {
        // hud.dismiss()
    }
}
