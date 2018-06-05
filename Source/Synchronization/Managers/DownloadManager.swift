//
//  DownloadManager.swift
//  SwiftyKanboard
//
//  Created by Dmytro Vorobiov on 13/06/2018.
//

import Foundation

protocol DownloadManager {
    var areRequiredSettingsSynchronized: Bool { get }
    func synchronizeRequiredSettings(completion: @escaping (() -> Void), failure: @escaping ((NetworkServiceError) -> Void))
}

