//
//  NSQueue.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.

import Foundation

class NSQueue<T : AnyObject> {
    private var array : Array<T>
    
    init() {
        array = Array<T>()
    }
    
    func offer(element : T) {
        array.append(element)
    }
    
    func poll() -> AnyObject? {
        var element : AnyObject? = nil
        if array.count > 0 {
            element = array.first
            array.removeFirst()
        }

        return element
    }
}