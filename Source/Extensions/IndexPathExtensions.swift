//
//  IndexPathExtensions.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 24/06/2018.
//

import Foundation

#if os(OSX)
extension IndexPath {
    init(row: Int, section: Int) {
        self.init(item: row, section: section)
    }

    var row: Int {
        set {
            item = newValue
        }
        get {
            return item
        }
    }
}
#endif
