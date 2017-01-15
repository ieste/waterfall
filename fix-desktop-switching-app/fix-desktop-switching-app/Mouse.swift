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
    return dummyEvent!.location
}


func mouseClick(_ location: CGPoint, doubleClick: Bool = false) {
    
    let tapLocation = CGEventTapLocation.cgSessionEventTap
    var down: CGEvent?
    var up: CGEvent?
  
    down = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: location, mouseButton: CGMouseButton.left)
    up = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseUp, mouseCursorPosition: location, mouseButton: CGMouseButton.left)
    
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
    var move: CGEvent?
    move = CGEvent(mouseEventSource: nil, mouseType: CGEventType.mouseMoved, mouseCursorPosition: location, mouseButton: CGMouseButton.left)
    if move != nil {
        move!.post(tap: CGEventTapLocation.cgSessionEventTap)
    }
}


func mouseHiddenClick(_ location: CGPoint, doubleClick: Bool = false) {
    let start = mouseGetCursorLocation()
    mouseClick(location, doubleClick: doubleClick)
    mouseMoveCursor(start)
}
