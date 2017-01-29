//
//  StartViewController.swift
//  Waterfall
//
//  Created by Isabella Stephens on 29/1/17.
//  Copyright © 2017 tonyandbella. All rights reserved.
//

import Cocoa

class StartViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func relaunch(sender: NSButton) {
        NSApplication.shared().relaunch(sender:nil)
    }
    
    @IBAction func quit(sender: NSButton) {
        NSApplication.shared().terminate(sender)
    }
    
}
