//
//  String.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-24.

import UIKit
import Foundation

extension String {
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        return nil
    }
}

extension String {
    subscript (r : NSRange) -> String {
        get {
            return self[rangeFromNSRange(r)!]
        }
    }
}

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let subStart = self.startIndex.advancedBy(r.startIndex, limit: self.endIndex)
            let subEnd = subStart.advancedBy(r.endIndex - r.startIndex, limit: self.endIndex)
            return self.substringWithRange(Range(start: subStart, end: subEnd))
        }
    }
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    func substring(from: Int) -> String {
        let end = self.characters.count
        return self[from..<end]
    }
    func substring(from: Int, length: Int) -> String {
        let end = from + length
        return self[from..<end]
    }
}

extension String {
    func toUIColorFromHex() -> UIColor {
        return UIColor(hexString: self)
    }
}

extension String {
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.max, height: height)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: [.UsesFontLeading, .UsesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
}

extension String {
    static func randomStringWithLength(len: Int) -> String {
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString = ""
        
        for (var i=0; i < len; i++){
            let length = UInt32(letters.characters.count)
            let rand = Int(arc4random_uniform(length))
            randomString.append(letters[letters.startIndex.advancedBy(rand)])
        }
        
        return randomString
    }
}

extension String {
    func sanitizedIRCString() -> String {
        //https://github.com/ircv3/ircv3-specifications/blob/master/core/message-tags-3.2.md#escaping-values
        return self
            .stringByReplacingOccurrencesOfString("\\:", withString: ";")
            .stringByReplacingOccurrencesOfString("\\s", withString: "")
            .stringByReplacingOccurrencesOfString("\\\\", withString: "\\")
            .stringByReplacingOccurrencesOfString("\\r", withString: "\r")
            .stringByReplacingOccurrencesOfString("\\n", withString: "\n")
    }
}