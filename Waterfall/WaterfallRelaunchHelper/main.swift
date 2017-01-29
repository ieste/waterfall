//
//  main.swift
//  WaterfallRelaunchHelper
//
//  Copied from:
//  http://stackoverflow.com/questions/27479801/restart-application-programmaticaly/39591935#39591935
//

import AppKit

// KVO helper
class Observer: NSObject {
    
    let _callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        _callback = callback
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        _callback()
    }
}


// main
autoreleasepool {
    
    // Extract the application PID from the command line args
    guard let parentPID = Int32(CommandLine.arguments[1]) else {
        NSLog("No PID received by WaterfallRelaunchHelper, can't relaunch app.")
        fatalError("Relaunch: parentPID == nil.")
    }
    
    // Get the application instance
    if let app = NSRunningApplication(processIdentifier: parentPID) {
        
        let bundleURL = app.bundleURL!
        
        // terminate() and wait terminated.
        NSLog("Terminating Waterfall application from relaunch helper.")
        let listener = Observer { CFRunLoopStop(CFRunLoopGetCurrent()) }
        app.addObserver(listener, forKeyPath: "isTerminated", context: nil)
        app.terminate()
        CFRunLoopRun() // wait KVO notification
        app.removeObserver(listener, forKeyPath: "isTerminated", context: nil)
        
        // Attempt to relaunch the application
        do {
            try NSWorkspace.shared().launchApplication(at: bundleURL, configuration: [:])
        } catch {
            NSLog("Application launch by WaterfallRelaunchHelper failed.")
            fatalError("Relaunch: NSWorkspace.shared().launchApplication failed.")
        }
    }
}
