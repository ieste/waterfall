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
import EventKit

let key_map : [Int64: Int] = [0x12:1, 0x13:2, 0x14:3, 0x15:4, 0x16:6, 0x17:5, 0x19:9, 0x1A:7, 0x1C:8, 0x1D:10]
let defaults = UserDefaults.standard

func getSpaces() -> [[Int]] {
    let mdata = defaults.dictionary(forKey: "SpacesDisplayConfiguration")!["Management Data"]! as! [String : Any]
    var uuids : [String] = []
    for monitor in mdata["Monitors"]! as! [[String : Any]] {
        if let spaces = monitor["Spaces"] {
            for space in spaces as! [[String:Any]] {
                uuids.append(space["uuid"]! as! String)
            }
        }
    }
    
    var retval : [[Int]] = []
    let spaces = defaults.dictionary(forKey: "SpacesDisplayConfiguration")!["Space Properties"]! as! [[String : Any]]
    for uuid in uuids {
        for space in spaces {
            if uuid == space["name"]! as! String {
                retval.append(space["windows"]! as! [Int])
                break
            }
        }
    }
    return retval
}

// This callback was registered and is run on every key down event
func myEventTapCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    // make sure that the only modifier is Control
    if !(event.flags.contains(.maskControl) &&
        !event.flags.contains(.maskAlphaShift) &&
        !event.flags.contains(.maskShift) &&
        !event.flags.contains(.maskNumericPad) &&
        !event.flags.contains(.maskSecondaryFn) &&
        //!event.flags.contains(.maskNonCoalesced) &&
        !event.flags.contains(.maskAlternate) &&
        !event.flags.contains(.maskCommand) &&
        !event.flags.contains(.maskHelp)) {
        return Unmanaged.passRetained(event);
    }
    
    let vkc = event.getIntegerValueField(.keyboardEventKeycode)
    if key_map[vkc] == nil {
        return Unmanaged.passRetained(event);
    }
    
    let digit = key_map[vkc]!
    if event.getIntegerValueField(.keyboardEventAutorepeat) != 0 {
        return nil;
    }
    
    let spaces = getSpaces()
    if (digit-1 >= spaces.count) {
        return nil;
    }

    print(spaces[digit-1])
    return nil;
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        var app: AXUIElement
        var pid: Int32 = 0
        var names: CFArray?
        
        // Add the suite to grab spaces information
        defaults.addSuite(named: "com.apple.spaces")
        
        // Create an event tap
        guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                          place: .tailAppendEventTap,
                                          options: .defaultTap,
                                          eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
                                          callback: myEventTapCallback,
                                          userInfo: nil) else {
            print("Could not create tap!");
            exit(0);
        }
        
        // Register event tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes);
        
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
            //AXUIElementSetAttributeValue(app, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
            
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

