//
//  EventMonitor.swift
//  Waterfall
//
//  Credit to Mikael Konutgan
//  https://www.raywenderlich.com/98178/os-x-tutorial-menus-popovers-menu-bar-apps
//

import Foundation
import Cocoa

public class EventMonitor {
    private var monitor: Any?
    private let mask: NSEventMask
    private let handler: (NSEvent?) -> ()
    
    public init(mask: NSEventMask, handler: @escaping (NSEvent?) -> ()) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask,
                                                    handler: handler)
    }
    
    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
