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
var windowList: [[String: Any]] = []

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
    
    let digit = key_map[vkc]! - 1
    if event.getIntegerValueField(.keyboardEventAutorepeat) != 0 {
        return nil;
    }
    
    let spaces = getSpaces()
    if (digit >= spaces.count) {
        return nil;
    }
    
    windowList = CGWindowListCopyWindowInfo(CGWindowListOption.optionAll, kCGNullWindowID) as! [[String: Any]]
    let visibleSpaces = getVisibleSpaces(spaces)
    print(visibleSpaces)
    
    if !visibleSpaces.contains(digit) {
        return Unmanaged.passRetained(event);
    }
    
    //print("\n\n\n--------------Desktop \(digit + 1)---------------")
    //printWindowDetails(spaces[digit])
    
    let window = findFrontmostWindow(spaces[digit])
    if window != nil {
        giveFocus(window!)
    }
    
    return nil;
}

func getVisibleSpaces(_ spaces: [[Int]]) -> [Int] {
    var retval: [Int] = []
    var i = 0
    for space in spaces {
        for wid in space {
            if isOnScreen(wid) && isBackgroundWindow(wid).bool {
                retval.append(i)
                break
            }
        }
        i += 1
    }
    return retval
}

func isOnScreen(_ wid: Int) -> Bool {
    for w in windowList {
        if wid == w["kCGWindowNumber"] as! Int {
            if w["kCGWindowIsOnscreen"] != nil {
                return true
            }
        }
    }
    return false
}

func isBackgroundWindow(_ wid: Int) -> (bool: Bool, bounds: [String: Int]?) {
    for w in windowList {
        if wid == w["kCGWindowNumber"] as! Int {
            if w["kCGWindowOwnerName"] as! String == "Dock" {
                return (true, w["kCGWindowBounds"] as! [String: Int])
            }
        }
    }
    return (false, nil)
}

func printWindowDetails(_ windows: [Int]) {
    // Loop through the list of windows and print out details
    for w in windowList {
        if windows.contains(w["kCGWindowNumber"] as! Int) {
            let bounds = w["kCGWindowBounds"] as! [String: Int]
            print("\(w["kCGWindowOwnerName"]!) (PID:\(w["kCGWindowOwnerPID"]!)) -- "
                + "window \(w["kCGWindowNumber"]!): \"\(w["kCGWindowName"]!)\"\n"
                + "On Screen: \(w["kCGWindowIsOnscreen"]), \(bounds["Height"]!) x \(bounds["Width"]!), "
                + "X: \(bounds["X"]!) Y: \(bounds["Y"]!) Z: \(w["kCGWindowLayer"]!)\n")
        }
    }
}

func isWindowIn(_ windowBounds : [String : Any], _ desktopBounds : [String : Any]) -> Bool {
    
    let wx = windowBounds["X"] as! Int
    let wx2 = wx + (windowBounds["Width"] as! Int)
    let wy = windowBounds["Y"] as! Int
    let wy2 = wy + (windowBounds["Height"] as! Int)
    let dx = desktopBounds["X"] as! Int
    let dx2 = dx + (desktopBounds["Width"] as! Int)
    let dy = desktopBounds["Y"] as! Int
    let dy2 = dy + (desktopBounds["Height"] as! Int)
    
    if (wx >= dx) && (wy >= dy) && (wx2 <= dx2) && (wy2 <= dy2) {
        return true
    }
    
    return false
}

func findFrontmostWindow(_ windows: [Int]) -> AXUIElement? {
    // Print out error if accessibility features are not enabled for this application
    if !AXIsProcessTrusted() {
        print("Error: accessibility features needs to be enabled.")
        return nil
    }
    
    var bounds: [String: Int] = [:]
    for wid in windows {
        let (bool, b) = isBackgroundWindow(wid)
        if bool {
            bounds = b!
            break
        }
    }
    
    let options = CGWindowListOption([CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly])
    let onScreen = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as! [[String: Any]]

    for w in onScreen {
        if isWindowIn(w["kCGWindowBounds"]! as! [String: Int], bounds) {
            let element = findUIElement(w)
            if isWindow(element) {
                return element
            }
        }
    }
    return nil
}

func findUIElement(_ window: [String: Any]) -> AXUIElement? {

    // Create a AXUIElement for the application based on the window's PID
    let pid = window["kCGWindowOwnerPID"] as! Int32
    let app = AXUIElementCreateApplication(pid)
    
    // Store the window's bounds
    let bounds = window["kCGWindowBounds"] as! [String: Int]
    
    // Get the children (windows) of the application and try to find the correct window
    var children: CFTypeRef?
    AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &children)
    if children == nil {
        return nil
    }
    let elements = children as! [AXUIElement]
    for e in elements {
        // Check if window title matches
        var title: CFTypeRef?
        AXUIElementCopyAttributeValue(e, kAXTitleAttribute as CFString, &title)
        if (title as! String) != (window["kCGWindowName"] as! String) {
            continue
        }
        // Check if window dimensions and position matches
        var position: CFTypeRef?
        var size: CFTypeRef?
        AXUIElementCopyAttributeValue(e, kAXPositionAttribute as CFString, &position)
        AXUIElementCopyAttributeValue(e, kAXSizeAttribute as CFString, &size)
        var p: CGPoint = CGPoint()
        var s: CGSize = CGSize()
        AXValueGetValue(position as! AXValue, AXValueType.cgPoint, &p)
        AXValueGetValue(size as! AXValue, AXValueType.cgSize, &s)
        if p.x == CGFloat(bounds["X"]!) &&
            p.y == CGFloat(bounds["Y"]!) &&
            s.width == CGFloat(bounds["Width"]!) &&
            s.height == CGFloat(bounds["Height"]!) {
            return e
        }
    }
    return nil
}

func isWindow(_ element: AXUIElement?) -> Bool {
    if element == nil {
        return false
    }
    
    var role: CFTypeRef?
    AXUIElementCopyAttributeValue(element!, kAXRoleAttribute as CFString, &role)
    if (role! as! String) != kAXWindowRole {
        return false
    }
    return true
}


func giveFocus(_ element: AXUIElement) {
    AXUIElementSetAttributeValue(element, kAXMainAttribute as CFString, kCFBooleanTrue)
    var parent: CFTypeRef?
    AXUIElementCopyAttributeValue(element, kAXParentAttribute as CFString, &parent)
    AXUIElementSetAttributeValue(parent as! AXUIElement, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
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

