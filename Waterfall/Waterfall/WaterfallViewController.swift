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

        // Make "launch at login" checkbox state consistent with user settings
        if UserDefaults.standard.bool(forKey: launchAtLogin) {
            launchCheckbox.state = 1
        } else {
            launchCheckbox.state = 0
        }
        
        // Make "hide menubar icon" checkbox state consistent with user settings
        if UserDefaults.standard.bool(forKey: hideMenubarIcon) {
            menuIconCheckbox.state = 1
        } else {
            menuIconCheckbox.state = 0
        }
    }

    @IBAction func quit(sender: NSButton) {
        NSApplication.shared().terminate(sender)
    }
    
    @IBAction func relaunch(sender: NSButton) {
        NSApplication.shared().relaunch(sender:nil)
    }
    
    @IBAction func launchChanged(sender: NSButton) {
        
        let bundleURL = "com.tonyandbella.WaterfallLaunchHelper"
        let appBundleIdentifier = NSString(string: bundleURL) as CFString
        
        if sender.state == 0 {
            UserDefaults.standard.set(false, forKey: launchAtLogin)
            SMLoginItemSetEnabled(appBundleIdentifier, false)
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


class StartViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func relaunch(sender: NSButton) {
        NSApplication.shared().relaunch(sender:nil)
    }
    
    @IBAction func quit(sender: NSButton) {
        NSApplication.shared().terminate(sender)
    }
}
