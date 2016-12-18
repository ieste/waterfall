//
//  main.swift
//  fix-desktop-switching
//
//  Created by Isabella Stephens on 17/12/2016.
//  Copyright © 2016 Tony and Bella. All rights reserved.
//

import Foundation
import CoreGraphics
import ApplicationServices


var app: AXUIElement
var nslist: NSArray!
var pid: Int32 = 0
var names: CFArray?


// Get the list of all windows and cast it to an array of Anys
let list = CGWindowListCopyWindowInfo(CGWindowListOption.optionAll, kCGNullWindowID) as! [Any]

// Loop through the list of windows and print out details of any chrome windows
for i in list {
    let window = i as! [String: Any]
    if window["kCGWindowOwnerName"] as! String == "Google Chrome" {
        /*
        print(window["kCGWindowNumber"] as Any)
        print(window["kCGWindowLayer"] as Any)
        print(window["kCGWindowBounds"] as Any)
        print(window["kCGWindowName"] as Any)
        print(window["kCGWindowOwnerPID"] as Any)
        print("   ")
        */
        pid = window["kCGWindowOwnerPID"] as! Int32
    }
}


// Create a Accessibility Element from the application's PID
if pid > 0 {
    
    var k = kAXTrustedCheckOptionPrompt
    var val = kCFBooleanTrue
    
    var options: NSDictionary = [k: val]
    
    //var values = [kCFBooleanTrue]
    //var options: CFDictionary = CFDictionaryCreate(kCFAllocatorDefault, &keys, &values, 1, NULL, NULL)
    //var value: CFBoolean = kCFBooleanTrue
    //var options: NSDictionary = [kAXTrustedCheckOptionPrompt: &value]
    
    
    let trusted = AXIsProcessTrustedWithOptions(options)
    print(trusted)
    
    print(pid)
    app = AXUIElementCreateApplication(pid)
    print(app)
    
    let error = AXUIElementCopyAttributeNames(app, &names)
    
    if error == .success {
        print("succeeded")
    } else if error == .invalidUIElement {
        
        print("failed")
    } else if error == .apiDisabled {
        print(2)
    } else if error == .actionUnsupported {
        print(3)
    } else if error == .cannotComplete {
        print(4)
    }
    
    
    
    
}




