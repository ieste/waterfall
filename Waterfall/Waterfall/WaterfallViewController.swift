//
//  WaterfallViewController.swift
//  Waterfall
//
//  Created by Isabella Stephens on 28/1/17.
//  Copyright © 2017 tonyandbella. All rights reserved.
//

import Cocoa
import ServiceManagement

class WaterfallViewController: NSViewController {
    
    @IBOutlet var launchCheckbox: NSButton!
    @IBOutlet var menuIconCheckbox: NSButton!
    
    let launchAtLogin = "launchAtLogin"
    let hideMenubarIcon = "hideMenubarIcon"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Make "launch at login" checkbox state consistent with user settings.
        if UserDefaults.standard.bool(forKey: launchAtLogin) {
            launchCheckbox.state = 1
        } else {
            launchCheckbox.state = 0
        }
        
        // Make "hide menubar icon" checkbox state consistent with user settings.
        if UserDefaults.standard.bool(forKey: hideMenubarIcon) {
            menuIconCheckbox.state = 1
        } else {
            menuIconCheckbox.state = 0
        }
    }

    @IBAction func quit(sender: NSButton) {
        NSApplication.shared().terminate(sender)
    }
    
    @IBAction func launchChanged(sender: NSButton) {
        
        let appBundleIdentifier = NSString(string: "com.tonyandbella.WaterfallLaunchHelper") as CFString
        
        if sender.state == 0 {
            UserDefaults.standard.set(false, forKey: launchAtLogin)
            if SMLoginItemSetEnabled(appBundleIdentifier, false) {
                NSLog("Removed login item.")
            } else {
                NSLog("Failed to remove login item.")
            }
        } else{
            UserDefaults.standard.set(true, forKey: launchAtLogin)
            if SMLoginItemSetEnabled(appBundleIdentifier, true) {
                NSLog("Added login item.")
            } else {
                NSLog("Failed to add login item.")
            }
        }
    }
    
    @IBAction func menuChanged(sender: NSButton) {
        if sender.state == 0 {
            UserDefaults.standard.set(false, forKey: hideMenubarIcon)
        } else {
            UserDefaults.standard.set(true, forKey: hideMenubarIcon)
        }
    }
}


