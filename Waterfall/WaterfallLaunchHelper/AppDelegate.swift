//
//  AppDelegate.swift
//  WaterfallLaunchHelper
//
//  Created by Isabella Stephens on 28/1/17.
//  Copyright © 2017 tonyandbella. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSLog("Trying to launch the app!")
        if NSWorkspace.shared().launchApplication("Waterfall") {
            NSLog("Successfully launched app.")
        } else {
            NSLog("Failed to launch app.")
        }
        NSApp.terminate(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

