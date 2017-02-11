//
//  main.swift
//  WaterfallRelaunchHelper
//
//  Created by Isabella Stephens on 11/2/17.
//  Copyright © 2017 Isabella Stephens and Tony Gong. All rights reserved.
//  License: BSD 3-Clause.
//

import AppKit

class terminationObserver: NSObject {
    
    var objectToObserve: NSRunningApplication
    
    init(_ app: NSRunningApplication) {
        objectToObserve = app
        super.init()
        objectToObserve.addObserver(self, forKeyPath: "isTerminated", context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        CFRunLoopStop(CFRunLoopGetCurrent())
    }
    
    
    deinit {
        objectToObserve.removeObserver(self, forKeyPath: "isTerminated", context: nil)
    }
}


autoreleasepool {
    // Get the current process ID
    guard let PID = pid_t(CommandLine.arguments[1]) else {
        return
    }
    
    if let app = NSRunningApplication(processIdentifier: PID) {
        let observer = terminationObserver(app)
        app.terminate()
        CFRunLoopRun()
        NSWorkspace.shared().launchApplication("Waterfall")
    }
}
