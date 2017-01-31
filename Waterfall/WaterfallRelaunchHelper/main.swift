//
//  main.swift
//  WaterfallRelaunchHelper
//
//  Credit to stackoverflow users: 3804019 and 597020
//  http://stackoverflow.com/questions/27479801
//

import AppKit

// KVO helper
class Observer: NSObject {
    
    let _callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        _callback = callback
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        _callback()
    }
}


// main
autoreleasepool {
    
    // Extract the application PID from the command line args
    guard let parentPID = Int32(CommandLine.arguments[1]) else {
#if DEBUG
        NSLog("No PID received by WaterfallRelaunchHelper, can't relaunch app.")
#endif
        fatalError("Relaunch: parentPID == nil.")
    }
    
    // Get the application instance
    if let app = NSRunningApplication(processIdentifier: parentPID) {
        
        let bundleURL = app.bundleURL!
        
        // terminate() and wait terminated.
#if DEBUG
        NSLog("Terminating Waterfall application from relaunch helper.")
#endif
        let listener = Observer { CFRunLoopStop(CFRunLoopGetCurrent()) }
        app.addObserver(listener, forKeyPath: "isTerminated", context: nil)
        app.terminate()
        CFRunLoopRun() // wait KVO notification
        app.removeObserver(listener, forKeyPath: "isTerminated", context: nil)
        
        // Attempt to relaunch the application
        do {
            try NSWorkspace.shared().launchApplication(at: bundleURL,
                                                       configuration: [:])
#if DEBUG
            NSLog("Application launch by WaterfallRelaunchHelper succeeded.")
#endif
        } catch {
#if DEBUG
            NSLog("Application launch by WaterfallRelaunchHelper failed.")
#endif
            fatalError("Relaunch: NSWorkspace.shared().launchApplication failed.")
        }
    }
}
