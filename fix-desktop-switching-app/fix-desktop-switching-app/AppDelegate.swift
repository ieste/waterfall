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
    
    print("\n\n\n--------------Desktop \(digit)---------------")
    printWindowDetails(windows: spaces[digit-1])
    return nil;
}

func printWindowDetails(windows: [Int]) {
    // Get the list of all windows and cast it to an array of dicts
    let windowList = CGWindowListCopyWindowInfo(CGWindowListOption.optionAll, kCGNullWindowID) as! [[String: Any]]
    // Loop through the list of windows and print out details
    for w in windowList {
        if windows.contains(w["kCGWindowNumber"] as! Int) {
            let bounds = w["kCGWindowBounds"] as! [String: Int]
            print("\(w["kCGWindowOwnerName"]!) (PID:\(w["kCGWindowOwnerPID"]!)) -- "
                + "window \(w["kCGWindowNumber"]!): \"\(w["kCGWindowName"]!)\"\n"
                + "\(bounds["Height"]!) x \(bounds["Width"]!), X: \(bounds["X"]!) Y: \(bounds["Y"]!) Z: \(w["kCGWindowLayer"]!)\n")
            if w["kCGWindowOwnerName"] as! String == "iTerm2" {
                giveWindowFocus(windowNumber: w["kCGWindowNumber"] as! Int)
            }
        }
    }
}

func giveWindowFocus(windowNumber: Int) {
    
    // Get all windows and find the one we are giving focus to
    let allWindows = CGWindowListCopyWindowInfo(CGWindowListOption.optionAll, kCGNullWindowID) as! [[String: Any]]
    
    for window in allWindows {
        if window["kCGWindowNumber"] as! Int == windowNumber {
            
            // Print out error if accessibility features are not enabled for this application
            if !AXIsProcessTrusted() {
                print("Error: accessibility features needs to be enabled.")
                return
            }
            
            // Windows lower than layer 0 can't be given focus
            //let layer = window["kCGWindowLayer"] as! Int
            
            let pid = window["kCGWindowOwnerPID"] as! Int32
            let bounds = window["kCGWindowBounds"]
            let name = window["kCGWindowName"]
            
            
            
            let app = AXUIElementCreateApplication(pid)
            
            // Print out the list of Accessibility Attributes for the App
            var names: CFArray?
            var children: CFTypeRef?
            //AXUIElementCopyAttributeNames(app, &names)
            //print(names as Any)
            //var candidates: [AXUIElement]
            //AXUIElementCopyAttributeValue(app, kAXChildrenAttribute as CFString, &children)
            AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &children)
            //print(children)
            
            let elements = children as! [AXUIElement]
            for e in elements {
                //print("\n\n")
                //AXUIElementCopyAttributeNames(e, &names)
                //print(names as Any)
                
                // Relevant attributes AXSize, AXTitle, AXPosition, AXFocused, AXMinimized...
                
                var windowName: CFTypeRef?
                AXUIElementCopyAttributeValue(e, kAXTitleAttribute as CFString, &windowName)
                print("\(windowName) -- \(name)")
                
                var size: CFTypeRef?
                var pos: CFTypeRef?
                AXUIElementCopyAttributeValue(e, kAXSizeAttribute as CFString, &size)
                AXUIElementCopyAttributeValue(e, kAXPositionAttribute as CFString, &pos)
                //print(size)
                //print(pos)
                //print(bounds)
                giveFocus(element: e)
                
                
                
            }
            // Set the app to be frontmost
            //AXUIElementSetAttributeValue(app, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
            
            //print(window)
            return
            
        }
    }
    print("Window not found")
}

func giveFocus(element: AXUIElement) {
    var names: CFArray?
    AXUIElementCopyActionNames(element, &names)
    //print(names)
    AXUIElementPerformAction(element, kAXRaiseAction as CFString)
    //AXUIElement
    AXUIElementSetAttributeValue(element, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
    AXUIElementSetAttributeValue(element, kAXFocusedAttribute as CFString, kCFBooleanTrue)
    
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
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
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

