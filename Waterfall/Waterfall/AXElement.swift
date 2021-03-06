//
//  AXElement.swift
//  Waterfall
//
//  Created by Isabella Stephens on 14/1/17.
//  Copyright © 2017 Isabella Stephens and Tony Gong. All rights reserved.
//  License: BSD 3-Clause.
//

import Foundation


func elementGiveFocus(_ element: AXUIElement) {
    guard elementIsWindow(element) else {
        NSLog("Cannot give focus to non-window UI element.")
        return
    }
        
    AXUIElementSetAttributeValue(element, kAXMainAttribute as CFString, kCFBooleanTrue)
    let parent = elementGetParent(element)
    if parent != nil && elementIsApplication(parent) {
        AXUIElementSetAttributeValue(parent!, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
    }
}


func elementIsWindow(_ element: AXUIElement?) -> Bool {
    
    guard element != nil else {
        return false
    }
    
    var role: CFTypeRef?
    var subrole: CFTypeRef?
    AXUIElementCopyAttributeValue(element!, kAXRoleAttribute as CFString, &role)
    AXUIElementCopyAttributeValue(element!, kAXSubroleAttribute as CFString, &subrole)
    
    guard (role != nil) && (subrole != nil) else {
        return false
    }
    
    if (role as! String) != kAXWindowRole || (((subrole as! String) != kAXStandardWindowSubrole)
                                              && ((subrole as! String) != kAXDialogSubrole))  {
        return false
    }
    
    return true
}


func elementIsApplication(_ element: AXUIElement?) -> Bool {
    if element == nil {
        return false
    }
    var role: CFTypeRef?
    AXUIElementCopyAttributeValue(element!, kAXRoleAttribute as CFString, &role)
    if role == nil {
        return false
    }
    if (role! as! String) != kAXApplicationRole {
        return false
    }
    return true
}


func elementGetPosition(_ element: AXUIElement) -> CGPoint? {
    var position: CFTypeRef?
    var p = CGPoint()
    AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &position)
    if position == nil {
        return nil
    }
    AXValueGetValue(position as! AXValue, AXValueType.cgPoint, &p)
    return p
}


func elementGetSize(_ element: AXUIElement) -> CGSize? {
    var size: CFTypeRef?
    var s = CGSize()
    AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &size)
    if size == nil {
        return nil
    }
    AXValueGetValue(size as! AXValue, AXValueType.cgSize, &s)
    return s
}


func elementGetBounds(_ element: AXUIElement) -> [String: Int]? {
    let position = elementGetPosition(element)
    let size = elementGetSize(element)
    if position == nil || size == nil {
        return nil
    }
    return ["X": Int(position!.x), "Y": Int(position!.y),
            "Width": Int(size!.width), "Height": Int(size!.height)]
}


func elementGetTitle(_ element: AXUIElement) -> String {
    var title: CFTypeRef?
    AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &title)
    if title == nil {
        return ""
    }
    return title as! String
}


func elementGetChildren(_ element: AXUIElement) -> [AXUIElement] {
    var children: CFTypeRef?
    AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children)
    if children == nil {
        return []
    }
    return children as! [AXUIElement]
}

func elementGetParent(_ element: AXUIElement) -> AXUIElement? {
    var parent: CFTypeRef?
    AXUIElementCopyAttributeValue(element, kAXParentAttribute as CFString, &parent)
    if parent == nil {
        return nil
    }
    return parent as! AXUIElement?
}
