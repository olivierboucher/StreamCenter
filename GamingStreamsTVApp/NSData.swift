//
//  NSData.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-17.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

extension NSData {
    func hasSuffix(bytes bytes: [UInt8]) -> Bool {
        if self.length < bytes.count { return false }
        let ptr = UnsafePointer<UInt8>(self.bytes)
        for (i, byte) in bytes.enumerate() {
            if ptr[self.length - bytes.count + i] != byte {
                return false
            }
        }
        return true
    }
}

extension NSMutableData {
    func appendBytes(bytes bytes: [UInt8]) {
        if bytes.count > 0 {
            self.appendBytes(UnsafePointer<UInt8>(bytes), length: bytes.count)
        }
    }
    
    func replaceBytesInRange(range : NSRange, bytes : [UInt8]) {
        let ptr = UnsafePointer<UInt8>(bytes)
        self.replaceBytesInRange(range, withBytes: ptr, length: bytes.count)
    }
}