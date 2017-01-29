//
//  AppDelegate.swift
//  Waterfall
//
//  Created by Isabella Stephens on 28/1/17.
//  Copyright © 2017 tonyandbella. All rights reserved.
//

import Cocoa
import AppKit
////////////////////////////////////////////////////
import Foundation
import CoreGraphics
import ApplicationServices
import EventKit


let key_map : [Int64: Int] = [0x12:1, 0x13:2, 0x14:3, 0x15:4, 0x16:6, 0x17:5, 0x19:9, 0x1A:7, 0x1C:8, 0x1D:10]
let defaults = UserDefaults.standard
var allWindows: [Int: [String:Any]] = [:]


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
    
    // Build dictionary of windows
    let windows = CGWindowListCopyWindowInfo(CGWindowListOption.optionAll, kCGNullWindowID) as! [[String: Any]]
    for w in windows {
        allWindows[w["kCGWindowNumber"] as! Int] = w
    }
    
    //print("\n\n\n--------------Desktop \(digit + 1)---------------")
    //printWindowDetails(spaces[digit])
    
    // Pass through key press if not for currently open desktop
    let visibleSpaces = getVisibleSpaces(spaces)
    if !visibleSpaces.contains(digit) || (visibleSpaces.count < 1) {
        return Unmanaged.passRetained(event);
    }
    
    
    guard let window = findFrontmostWindow(spaces[digit]) else {
        // If no frontmost window can be found, give focus to desktop by clicking menu bar
        guard let bounds = getDesktopBounds(spaces[digit]) else { return nil }
        let clickPoint = CGPoint(x: (bounds["X"]! + (bounds["Width"]! - 5)), y: (bounds["Y"]! + 5))
        mouseHiddenClick(clickPoint, rightClick: true)
        return nil
    }

    guard let point = elementGetPosition(window) else { return nil }
    NSLog("\(point)")
    mouseHiddenClick(point)
    return nil;
}


func isOnScreen(_ wid: Int) -> Bool {
    guard let window = allWindows[wid] else { return false }
    
    if window["kCGWindowIsOnscreen"] != nil {
        return true
    }
    return false
}


func isBackgroundWindow(_ wid: Int) -> [String: Int]? {
    guard let window = allWindows[wid] else { return nil }
    
    if (window["kCGWindowOwnerName"] as! String) == "Dock" {
        return window["kCGWindowBounds"] as! [String: Int]
    }
    
    return nil
}


func getVisibleSpaces(_ spaces: [[Int]]) -> [Int] {
    var retval: [Int] = []
    var i = 0
    for space in spaces {
        for wid in space {
            if isOnScreen(wid) && (isBackgroundWindow(wid) != nil) {
                retval.append(i)
                break
            }
        }
        i += 1
    }
    return retval
}


func printWindowDetails(_ windows: [Int]) {
    // Loop through the list of windows and print out details
    var w: [String: Any]?
    for wid in windows {
        w = allWindows[wid]
        if w != nil {
            let bounds = w!["kCGWindowBounds"] as! [String: Int]
            print("\(w!["kCGWindowOwnerName"]!) (PID:\(w!["kCGWindowOwnerPID"]!)) -- "
                + "window \(w!["kCGWindowNumber"]!): \"\(w!["kCGWindowName"]!)\"\n"
                + "On Screen: \(w!["kCGWindowIsOnscreen"]), \(bounds["Height"]!) x \(bounds["Width"]!), "
                + "X: \(bounds["X"]!) Y: \(bounds["Y"]!) Z: \(w!["kCGWindowLayer"]!)\n")
        }
    }
}


func isWindowIn(_ windowBounds: [String: Any], _ desktopBounds: [String: Any], fully: Bool = true) -> Bool {
    
    let wx = windowBounds["X"] as! Int
    let wx2 = wx + (windowBounds["Width"] as! Int)
    let wy = windowBounds["Y"] as! Int
    let wy2 = wy + (windowBounds["Height"] as! Int)
    let dx = desktopBounds["X"] as! Int
    let dx2 = dx + (desktopBounds["Width"] as! Int)
    let dy = desktopBounds["Y"] as! Int
    let dy2 = dy + (desktopBounds["Height"] as! Int)
    

    if (wx >= dx) && (wy >= dy) && (wx2 <= dx2) && (wy2 <= dy2) && fully {
        return true
    } else if fully || (wx > dx2) || (wx2 < dx) || (wy > dy2) || (wy2 < dy) {
        return false
    }
    return true
}


func listDesktops() -> [[String: Any]] {
    var desktops: [[String: Any]] = []
    
    let onScreen = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as! [[String: Any]]
    for window in onScreen {
        if let bounds = isBackgroundWindow(window["kCGWindowNumber"] as! Int) {
            desktops.append(bounds)
        }
    }
    
    return desktops
}


func intersectCount(_ windowBounds: [String: Any]) -> Int {
    var count = 0
    
    let desktops = listDesktops()
    for desktopBounds in desktops {
        if isWindowIn(windowBounds, desktopBounds, fully: false) { count = count + 1 }
    }
    return count
}


func findFrontmostWindow(_ windows: [Int]) -> AXUIElement? {
    
    // Get the bounds of the desktop (space) we are looking at
    guard let desktopBounds = getDesktopBounds(windows) else {
        NSLog("Finding frontmost window failed as desktop bounds couldn't be retreived.")
        return nil
    }

    let options = CGWindowListOption([CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly])
    let onScreen = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as! [[String: Any]]
    
    for window in onScreen {
        guard let bounds = window["kCGWindowBounds"] else { continue }
        let windowBounds = bounds as! [String: Int]
        if isWindowIn(windowBounds, desktopBounds, fully: false) && intersectCount(windowBounds) == 1 {
            let element = findUIElement(window)
            if elementIsWindow(element) {
                return element
            }
        }
    }

    return nil
}


func getDesktopBounds(_ windows: [Int]) -> [String: Int]? {
    for wid in windows {
        guard let bounds = isBackgroundWindow(wid) else { continue }
        return bounds
    }
    return nil
}


func findUIElement(_ window: [String: Any]) -> AXUIElement? {
    
    // Create a AXUIElement for the application based on the window's PID
    let pid = window["kCGWindowOwnerPID"] as! Int32
    let app = AXUIElementCreateApplication(pid)
    
    let bounds = window["kCGWindowBounds"] as! [String: Int]
    var title = ""
    if window["kCGWindowName"] != nil {
        title = window["kCGWindowName"] as! String
    }
    
    for e in elementGetChildren(app) {
        if elementGetTitle(e) == title && elementGetBounds(e)! == bounds {
            return e
        }
    }
    
    return nil
}



/////////////////////////////////////////////////


extension NSApplication {
    func relaunch(sender: AnyObject?) {
        let task = Process()
        // helper tool path
        task.launchPath = Bundle.main.path(forResource: "WaterfallRelaunchHelper", ofType: nil)!
        // self PID as a argument
        task.arguments = [String(ProcessInfo.processInfo.processIdentifier)]
        task.launch()
    }
}



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.system().statusItem(withLength:-2)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    let launchAtLogin = "launchAtLogin"
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Create the menu bar button and link it to the toggle popover callback
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuButton")
            button.action = #selector(AppDelegate.togglePopover)
        }
        
        // Check a setting exists for launch at login
        let launchSetting = UserDefaults.standard.string(forKey: launchAtLogin)
        if launchSetting == nil {
            UserDefaults.standard.set(false, forKey: launchAtLogin)
        }
        
        // Set the controller for the popover
        popover.contentViewController = WaterfallViewController(nibName: "WaterfallViewController", bundle: nil)
        
        // Create an event monitor for tracking clicks outside of the popover (to close it)
        let mask = NSEventMask([NSEventMask.leftMouseDown, NSEventMask.rightMouseDown])
        eventMonitor = EventMonitor(mask: mask) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(sender: event)
            }
        }
        eventMonitor?.start()
        
        
        //////////////////////////////////////////////////////////
        // Add the suite to grab spaces information
        defaults.addSuite(named: "com.apple.spaces")
        
        // Create an event tap
        guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                          place: .tailAppendEventTap,
                                          options: .defaultTap,
                                          eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
                                          callback: myEventTapCallback,
                                          userInfo: nil)
        else {
            NSLog("Could not create tap!");
            exit(0);
        }
        
        // Register event tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes);
        /////////////////////////////////////////////////////////////
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        NSLog("Waterfall application has terminated.")
    }
    
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    
    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
}

