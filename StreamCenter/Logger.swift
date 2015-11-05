//
//  Logger.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-28.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

struct Logger {
    
    static let dateFormatter = NSDateFormatter(format: "HH:mm:ss")
    static var level : LogLevel = .Info
    
    static func Info<Object>(object : Object, _ file : String = __FILE__, _ function : String = __FUNCTION__, _ line : Int = __LINE__) {
        let level = LogLevel.Info
        
        if level >= self.level {
            let prefix = self.getPrefix(file, function: function, line: line)
            let text = escapeAndPrettify(object)
            print(ColorLog.infoColor(prefix), terminator: "")
            print(ColorLog.lightGreen("\t>> \(text)\n"), terminator: "")
        }
        
    }
    
    static func Debug<Object>(object : Object, _ file : String = __FILE__, _ function : String = __FUNCTION__, _ line : Int = __LINE__) {
        let level = LogLevel.Debug
        
        if level >= self.level {
            let prefix = self.getPrefix(file, function: function, line: line)
            let text = escapeAndPrettify(object)
            print(ColorLog.infoColor(prefix), terminator: "")
            print(ColorLog.green("\t>> \(text)\n"), terminator: "")
        }
    }
    
    static func Warning<Object>(object : Object, _ file : String = __FILE__, _ function : String = __FUNCTION__, _ line : Int = __LINE__) {
        let level = LogLevel.Warning
        
        if level >= self.level {
            let prefix = self.getPrefix(file, function: function, line: line)
            let text = escapeAndPrettify(object)
            print(ColorLog.infoColor(prefix), terminator: "")
            print(ColorLog.yellow("\t>> \(text)\n"), terminator: "")
        }
    }
    
    static func Error<Object>(object : Object, _ file : String = __FILE__, _ function : String = __FUNCTION__, _ line : Int = __LINE__) {
        let level = LogLevel.Error
        
        if level >= self.level {
            let prefix = self.getPrefix(file, function: function, line: line)
            let text = escapeAndPrettify(object)
            print(ColorLog.infoColor(prefix), terminator: "")
            print(ColorLog.orange("\t>> \(text)\n"), terminator: "")
        }
    }
    
    static func Severe<Object>(object : Object, _ file : String = __FILE__, _ function : String = __FUNCTION__, _ line : Int = __LINE__) {
        let level = LogLevel.Severe
        
        if level >= self.level {
            let prefix = self.getPrefix(file, function: function, line: line)
            let text = escapeAndPrettify(object)
            print(ColorLog.infoColor(prefix), terminator: "")
            print(ColorLog.red("\t>> \(text))\n"), terminator: "")
        }
    }
    
    private static func getPrefix(file : String, function : String, line : Int) -> String {
        let label = String(UTF8String : dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        let time = dateFormatter.stringFromDate(NSDate())
        
        return "[\(time)] @\(label) - \(file.fileName).\(function) - [\(line)]\n"
    }
    
    private static func escapeAndPrettify<Object>(object : Object) -> String {
        var s = "\(object)"
        
        if s.hasSuffix("\r\n"){
            s = s[0..<s.characters.count - 1]
        }
        
        if s.hasSuffix("\n"){
            s = s[0..<s.characters.count]
        }
        
        return s.stringByReplacingOccurrencesOfString("\n", withString: "\n\t>> ")
    }
    
}

enum LogLevel : Int {
    case Info = 1,
    Debug,
    Warning,
    Error,
    Severe
}

func > (left: LogLevel, right: LogLevel) -> Bool {
    return left.rawValue > right.rawValue
}
func >= (left: LogLevel, right: LogLevel) -> Bool {
    return left.rawValue >= right.rawValue
}
func < (left: LogLevel, right: LogLevel) -> Bool {
    return left.rawValue < right.rawValue
}
func <= (left: LogLevel, right: LogLevel) -> Bool {
    return left.rawValue <= right.rawValue
}

private struct ColorLog {
    private static let ESCAPE = "\u{001b}["
    private static let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
    private static let RESET_BG = ESCAPE + "bg;" // Clear any background color
    private static let RESET = ESCAPE + ";"      // Clear any foreground or background color
    
    static func infoColor<T>(object:T) -> String {
        return "\(ESCAPE)fg120,120,120;\(object)\(RESET)"
    }
    
    static func purple<T>(object:T) -> String {
        return "\(ESCAPE)fg160,32,240;\(object)\(RESET)"
    }
    
    static func lightGreen<T>(object:T) -> String {
        return "\(ESCAPE)fg0,180,180;\(object)\(RESET)"
    }
    
    static func green<T>(object:T) -> String {
        return "\(ESCAPE)fg0,150,0;\(object)\(RESET)"
    }
    
    static func yellow<T>(object:T) -> String {
        return "\(ESCAPE)fg255,190,0;\(object)\(RESET)"
    }
    
    static func orange<T>(object:T) -> String {
        return "\(ESCAPE)fg255,128,0;\(object)\(RESET)"
    }
    
    static func red<T>(object:T) -> String {
        return "\(ESCAPE)fg255,0,0;\(object)\(RESET)"
    }
    
}


private extension String {
    
    var ns : NSString {
        return self as NSString
    }
    var fileName: String {
        return self.ns.lastPathComponent.ns.stringByDeletingPathExtension
    }
    
}