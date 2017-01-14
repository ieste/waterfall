//
//  Mouse.swift
//  fix-desktop-switching-app
//
//  Created by Isabella Stephens on 14/1/17.
//  Copyright © 2017 Tony and Bella. All rights reserved.
//

import Foundation


func getCursorLocation() -> CGPoint {
    let dummyEvent = CGEvent(source: nil)
    return dummyEvent!.location
}

func click(_ location: CGPoint, _ doubleClick: Bool = false) {
    var down: CGEvent?
    var up: CGEvent?
    down = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: location, mouseButton: CGMouseButton.left)
    up = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseUp, mouseCursorPosition: location, mouseButton: CGMouseButton.left)
    
    down!.post(tap: CGEventTapLocation.cgSessionEventTap)
    up!.post(tap: CGEventTapLocation.cgSessionEventTap)
    if doubleClick {
        down!.post(tap: CGEventTapLocation.cgSessionEventTap)
        up!.post(tap: CGEventTapLocation.cgSessionEventTap)
    }
}

func moveCursor(_ location: CGPoint) {
    var move: CGEvent?
    move = CGEvent(mouseEventSource: nil, mouseType: CGEventType.mouseMoved, mouseCursorPosition: location, mouseButton: CGMouseButton.left)
    if move != nil {
        move!.post(tap: CGEventTapLocation.cgSessionEventTap)
    }
}

func hiddenClick(_ location: CGPoint, _ doubleClick: Bool = false) {
    let start = getCursorLocation()
    click(location, doubleClick)
    moveCursor(start)
}
