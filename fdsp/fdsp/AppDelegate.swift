//
//  AppDelegate.swift
//  fdsp
//
//  Created by Isabella Stephens on 28/1/17.
//  Copyright © 2017 tonyandbella. All rights reserved.
//

import Cocoa
import AppKit


extension NSApplication {
    func relaunch(sender: AnyObject?) {
        let task = Process()
        // helper tool path
        task.launchPath = Bundle.main.path(forResource: "relaunch", ofType: nil)!
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
        print(launchSetting)
        
        // Set the controller for the popover
        popover.contentViewController = fdspViewController(nibName: "fdspViewController", bundle: nil)
        
        // Create an event monitor for tracking clicks outside of the popover (to close it)
        let mask = NSEventMask([NSEventMask.leftMouseDown, NSEventMask.rightMouseDown])
        eventMonitor = EventMonitor(mask: mask) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(sender: event)
            }
        }
        eventMonitor?.start()
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            //popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSMinYEdge)
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

