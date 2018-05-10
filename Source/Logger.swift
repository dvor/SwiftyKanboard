//
//  Logger.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 10/05/2018.
//

import Foundation

func log (_ string: String, filename: NSString = #file) {
    NSLog("\(filename.lastPathComponent): \(string)")
}
