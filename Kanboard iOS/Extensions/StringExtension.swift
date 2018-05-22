//
//  StringExtension.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 23/05/2018.
//

import Foundation

extension String {
    init(localized: String, _ arguments: CVarArg...) {
        let format = NSLocalizedString(localized, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        self.init(format: format, arguments: arguments)
    }

    init(localized: String, comment: String, _ arguments: CVarArg...) {
        let format = NSLocalizedString(localized, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
        self.init(format: format, arguments: arguments)
    }
}
