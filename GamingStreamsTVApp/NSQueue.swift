//
//  NSQueue.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class NSQueue<T : AnyObject> {
    private let array : NSMutableArray
    
    init() {
        array = NSMutableArray()
    }
    
    func push(element : T) {
        array.addObject(element)
    }
    
    func pop() -> AnyObject? {
        var element : AnyObject? = nil
        if array.count > 0 {
            element = array.objectAtIndex(0)
            array.removeObjectAtIndex(0)
        }

        return element
    }
}