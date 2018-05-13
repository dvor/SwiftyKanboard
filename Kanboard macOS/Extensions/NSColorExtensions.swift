//
//  NSColorExtensions.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import AppKit

extension NSColor {
        func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }

    func darkerColor(_ delta: CGFloat) -> NSColor {
        let (red, green, blue, alpha) = components()

        return NSColor(red: max(red - delta, 0.0), green: max(green - delta, 0.0), blue: max(blue - delta, 0.0), alpha: alpha)
    }
}
