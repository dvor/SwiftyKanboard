//
//  BoardCollectionViewItem.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/05/2018.
//

import AppKit
import Foundation
import SnapKit

class ViewWithBackground: NSView {
    var backgroundColor: NSColor?

    override func draw(_ dirtyRect: NSRect) {
        backgroundColor?.setFill()
        dirtyRect.fill()

        super.draw(dirtyRect)
    }
}

class BoardCollectionViewItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("BoardCollectionViewItem")

    private var backgroundView: ViewWithBackground!
    private var textView: NSTextView!

    var name: String? {
        didSet {
            textView.string = name ?? ""
        }
    }

    var backgroundColor: NSColor? {
        didSet {
            updateBackgroundColor()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateBackgroundColor()
        }
    }

    override func loadView() {
        backgroundView = ViewWithBackground()
        view = backgroundView

        textView = NSTextView()
        textView.backgroundColor = NSColor.clear
        textView.isEditable = false
        view.addSubview(textView)

        textView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }

    func redraw() {
        view.needsUpdateConstraints = true
        view.setNeedsDisplay(view.bounds)
    }

    private func updateBackgroundColor() {
        backgroundView.backgroundColor = isSelected ? backgroundColor?.darkerColor(0.2) : backgroundColor
        view.setNeedsDisplay(view.bounds)
    }
}
