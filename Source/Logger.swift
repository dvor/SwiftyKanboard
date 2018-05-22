//
//  Logger.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Willow

class LogLevelModifier: LogModifier {
    func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
        return "[\(logLevel.description)] \(message)"
    }
}

let log = Logger(logLevels: [.all],
                 writers: [ConsoleWriter(modifiers: [LogLevelModifier(), TimestampModifier()])])
