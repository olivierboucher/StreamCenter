//
//  Dictionary.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-25.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[startIndex.advancedBy(i)]
        }
    }
}