//
//  TaskColorExtension.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 21/05/2018.
//

import Foundation

extension TaskColor: Synchronizable {
    func isEqual(to remote: RemoteObject) -> Bool {
        guard let color = remote as? RemoteTaskColor else {
            fatalError("Passed object of wrong type")
        }

        return
            id              == color.id &&
            name            == color.name &&
            backgroundRed   == color.backgroundRed &&
            backgroundGreen == color.backgroundGreen &&
            backgroundBlue  == color.backgroundBlue &&
            borderRed       == color.borderRed &&
            borderGreen     == color.borderGreen &&
            borderBlue      == color.borderBlue
    }

    func update(with remote: RemoteObject) {
        guard let color = remote as? RemoteTaskColor else {
            fatalError("Passed object of wrong type")
        }

        name            = color.name
        backgroundRed   = color.backgroundRed
        backgroundGreen = color.backgroundGreen
        backgroundBlue  = color.backgroundBlue
        borderRed       = color.borderRed
        borderGreen     = color.borderGreen
        borderBlue      = color.borderBlue
    }
}
