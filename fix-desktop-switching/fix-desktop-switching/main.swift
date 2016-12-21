//
//  main.swift
//  fix desktop switching
//
//  Created by Tony Gong on 12/17/16.
//  Copyright © 2016 Tony and Bella. All rights reserved.
//

import Foundation

let defaults = UserDefaults.standard
defaults.addSuite(named: "com.apple.spaces")
let spaces = defaults.dictionary(forKey: "SpacesDisplayConfiguration")!["Space Properties"]! as! [[String : Any]]
for space in spaces {
    print(space["windows"]!)
}
