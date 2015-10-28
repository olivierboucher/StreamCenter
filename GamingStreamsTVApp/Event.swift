//
//  Event.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-28.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class Event {
    let name : String
    var properties : [String : AnyObject]
    
    init(name : String, properties : [String : AnyObject]) {
        self.name = name
        self.properties = properties
        self.properties["time"] = NSDate().timeIntervalSince1970
    }
    
    
}