//
//  Mouse.swift
//  fix-desktop-switching-app
//
//  Created by Isabella Stephens on 14/1/17.
//  Copyright © 2017 Tony and Bella. All rights reserved.
//

import Foundation


func mouseGetCursorLocation() -> CGPoint {
    // Attempt to create dummy even
    let dummyEvent = CGEvent(source: nil)
    if dummyEvent == nil {
        NSLog("Mouse location could not be retrieved.")
        return CGPoint(x: 0, y: 0)
    }
    
    // Return the dummy event's location (this will be the cursor location)
    return dummyEvent!.location
}


func mouseClick(_ location: CGPoint, doubleClick: Bool = false,
                rightClick: Bool = false) {
    
    let tapLocation = CGEventTapLocation.cgSessionEventTap
    
    var downEventType = CGEventType.leftMouseDown
    var upEventType = CGEventType.leftMouseUp
    var button = CGMouseButton.left
    if rightClick {
        downEventType = CGEventType.rightMouseDown
        upEventType = CGEventType.rightMouseUp
        button = CGMouseButton.right
    }
    
    let down = CGEvent(mouseEventSource: nil, mouseType: downEventType,
                       mouseCursorPosition: location, mouseButton: button)
    let up = CGEvent(mouseEventSource: nil, mouseType: upEventType,
                     mouseCursorPosition: location, mouseButton: button)

    guard down != nil && up != nil else {
        NSLog("Mouse click event could not be created.")
        return
    }
    
    down!.flags.remove(.maskControl)
    up!.flags.remove(.maskControl)

    down!.post(tap: tapLocation)
    up!.post(tap: tapLocation)
    if doubleClick {
        down!.post(tap: tapLocation)
        up!.post(tap: tapLocation)
    }
}


func mouseMoveCursor(_ location: CGPoint) {
    let move = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                       mouseCursorPosition: location, mouseButton: .left)
    if move != nil {
        move!.post(tap: CGEventTapLocation.cgSessionEventTap)
    } else {
        NSLog("Mouse move event could not be created.")
    }
}


func mouseHiddenClick(_ location: CGPoint, doubleClick: Bool = false,
                      rightClick: Bool = false) {
    let start = mouseGetCursorLocation()
    mouseClick(location, doubleClick: doubleClick, rightClick: rightClick)
    mouseMoveCursor(start)
}
