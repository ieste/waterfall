//
//  Mouse.swift
//  fix-desktop-switching-app
//
//  Created by Isabella Stephens on 14/1/17.
//  Copyright © 2017 Tony and Bella. All rights reserved.
//

import Foundation


func mouseGetCursorLocation() -> CGPoint {
    let dummyEvent = CGEvent(source: nil)
    
    if dummyEvent == nil {
        NSLog("Mouse location could not be retrieved.")
        return CGPoint(x: 0, y: 0)
    }
    
    return dummyEvent!.location
}


func mouseClick(_ location: CGPoint, doubleClick: Bool = false) {
    
    let tapLocation = CGEventTapLocation.cgSessionEventTap
    
    let down = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: location, mouseButton: CGMouseButton.left)
    let up = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseUp, mouseCursorPosition: location, mouseButton: CGMouseButton.left)

    if down == nil || up == nil {
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
    let move = CGEvent(mouseEventSource: nil, mouseType: CGEventType.mouseMoved, mouseCursorPosition: location, mouseButton: CGMouseButton.left)
    if move != nil {
        move!.post(tap: CGEventTapLocation.cgSessionEventTap)
    } else {
        NSLog("Mouse move event could not be created.")
    }
}


func mouseHiddenClick(_ location: CGPoint, doubleClick: Bool = false) {
    let start = mouseGetCursorLocation()
    mouseClick(location, doubleClick: doubleClick)
    mouseMoveCursor(start)
}
