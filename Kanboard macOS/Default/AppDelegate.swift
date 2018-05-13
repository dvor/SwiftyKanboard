//
//  AppDelegate.swift
//  Kanboard macOS
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: MainWindowController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainWindowController = MainWindowController(windowNibName: NSNib.Name(rawValue: "MainWindowController"))
        mainWindowController.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

