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
    
    init(name : String, properties : [String : AnyObject]) {
        self.name = name
        self.properties = properties
        self.properties["time"] = NSDate().timeIntervalSince1970
    }
    
    mutating func signedSelf(token : String) -> Event {
        self.properties["token"] = token
        return self
    }
    
    static func InitializeEvent() -> Event {
        return Event(name: "App start", properties: [:])
    }
}

//Little hack to get the array extension to work
protocol EventType {}
extension Event : EventType {}

extension Array where Element : EventType {
    func getJSONConvertible() -> [[String : AnyObject]] {
        var dictArray = [[String : AnyObject]]()
        for element in self {
            let event = element as! Event
            dictArray.append([
                "event" : event.name,
                "properties" : event.properties
            ])
        }
        return dictArray
    }
}
