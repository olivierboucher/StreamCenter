//
//  Event.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-28.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation



struct Event {
    let name : String
    var properties : [String : AnyObject]
    
    init(name : String, properties : [String : AnyObject]?) {
        self.name = name
        if let properties = properties {
            self.properties = properties
        } else {
            self.properties = [ : ]
        }
        self.properties["time"] = NSDate().timeIntervalSince1970
    }
    
    mutating func signedSelf(token : String) -> Event {
        self.properties["token"] = token
        return self
    }
    
    static func InitializeEvent() -> Event {
        return Event(name: "App start", properties: nil)
    }
    
    static func ServiceAuthenticationEvent(serviceName: String) -> Event {
        return Event(name: "Service Authentication", properties: ["service" : serviceName])
    }
    
    var jsonDictionary: [String : AnyObject] {
        get {
            return [
                "event" : self.name,
                "properties" : self.properties
            ]
        }
    }
}
