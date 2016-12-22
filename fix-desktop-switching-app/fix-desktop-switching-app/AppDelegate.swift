//
//  AppDelegate.swift
//  fix-desktop-switching-app
//
//  Created by Isabella Stephens on 18/12/2016.
//  Copyright © 2016 Tony and Bella. All rights reserved.
//

import Cocoa
import Foundation
import CoreGraphics
import ApplicationServices

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {

        var app: AXUIElement
        var pid: Int32 = 0
        var names: CFArray?
        
        // Get the list of all windows and cast it to an array of Anys
        let list = CGWindowListCopyWindowInfo(CGWindowListOption.optionAll, kCGNullWindowID) as! [Any]
        
        // Loop through the list of windows and find the PID of Chrome
        for i in list {
            let window = i as! [String: Any]
            if window["kCGWindowOwnerName"] as! String == "Google Chrome" {
                
                pid = window["kCGWindowOwnerPID"] as! Int32
                
                /*
                 print(window["kCGWindowNumber"] as Any)
                 print(window["kCGWindowLayer"] as Any)
                 print(window["kCGWindowBounds"] as Any)
                 print(window["kCGWindowName"] as Any)
                 print(window["kCGWindowOwnerPID"] as Any)
                 print("   ")
                 */
            }
        }
        
        
        // Create a Accessibility Element from the application's PID
        if pid > 0 {
            
            print(pid)
            
            // Print out whether accessibility features are enabled for this application
            let trusted = AXIsProcessTrusted()
            print(trusted)
            app = AXUIElementCreateApplication(pid)
            
            // Print out the list of Accessibility Attributes for the App
            let error = AXUIElementCopyAttributeNames(app, &names)
            if error == .success {
                print("succeeded")
            } else if error == .apiDisabled {
                print("Accessibility API is disabled")
            }
            print(names as Any)
            
            // Set the app to be frontmost
            AXUIElementSetAttributeValue(app, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
            
        }

        let defaults = UserDefaults.standard
        defaults.addSuite(named: "com.apple.spaces")
        let spaces = defaults.dictionary(forKey: "SpacesDisplayConfiguration")!["Space Properties"]! as! [[String : Any]]
        for space in spaces {
            print(space["windows"]!)
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

