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
        
        // Attempt to launch Waterfall
        if NSWorkspace.shared().launchApplication("Waterfall") { NSLog("Successfully launched Waterfall from WaterfallLaunchHelper.") }
        else { NSLog("Failed to launch Waterfall from WaterfallLaunchHelper.") }
        
        // Terminate the helper application
        NSApp.terminate(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {}
}

