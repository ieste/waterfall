//
//  AppDelegate.swift
//  WaterfallLaunchHelper
//
//  Created by Isabella Stephens on 28/1/17.
//  Copyright © 2017 Isabella Stephens and Tony Gong. All rights reserved.
//  License: BSD 3-Clause.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Attempt to launch Waterfall
        if NSWorkspace.shared().launchApplication("Waterfall") {
#if DEBUG
            NSLog("Successfully launched Waterfall from WaterfallLaunchHelper.")
#endif
        } else {
#if DEBUG
            NSLog("Failed to launch Waterfall from WaterfallLaunchHelper.")
#endif
        }
        
        // Terminate the helper application
        NSApp.terminate(nil)
    }
}

