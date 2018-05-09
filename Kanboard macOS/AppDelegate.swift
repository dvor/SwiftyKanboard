//
//  AppDelegate.swift
//  Kanboard macOS
//
//  Created by Dmytro Vorobiov on 09/05/2018.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let service = NetworkService()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        let r1 = service.createRequest(GetAllProjectsRequest.self) { projects in print(projects)}
        let r2 = service.createRequest(GetVersionRequest.self) { projects in print(projects)}
        service.batch([r1, r2])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

