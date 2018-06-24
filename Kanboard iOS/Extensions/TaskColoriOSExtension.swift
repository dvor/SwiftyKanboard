//
//  TaskColoriOSExtension.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/06/2018.
//

import UIKit

extension TaskColor {
    var backgroundColor: UIColor {
        get {
            return UIColor(red: CGFloat(backgroundRed),
                           green: CGFloat(backgroundGreen),
                           blue: CGFloat(backgroundBlue),
                           alpha: 1.0)
        }
    }

    var borderColor: UIColor {
        get {
            return UIColor(red: CGFloat(borderRed),
                           green: CGFloat(borderGreen),
                           blue: CGFloat(borderBlue),
                           alpha: 1.0)
        }
    }
}
