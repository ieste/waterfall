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
let array = defaults.dictionary(forKey: "SpacesDisplayConfiguration")!["Space Properties"]! as! [Any]
let dict2 = array[0] as! [String : Any]
print(dict2)
let string = dict2["name"]
print(type(of: string))
print(string)
//for a in array {
//    let tuple = a[cWindow]
//    print(type(of: tuple))
//    print(tuple)
//}
