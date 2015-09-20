//
//  TwitchChatHandler.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-19.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchChatHandler : IRCHandlerBase {
    var loopTimer: NSTimer?
    var isAnonymous : Bool = false
    var recieveTextCallback : ((prefix: String?, command: String , destination: String?, message: String?) -> Void)?
    
    init() {
        super.init(host: "irc.twitch.tv", port: 6667, useSSL: false)
    }
    
    func anonymousConnect() {
        isAnonymous = true
        super.connect()
        self.acquireNewAnonymousNick()
        
        commandHandlers["PING"] = TwitchChatIRCDelegate_PING()
        
        //Errors
        commandHandlers["433"] = TwitchChatIRCDelegate_433()
        commandHandlers["466"] = TwitchChatIRCDelegate_466()
    }
    
    func acquireNewAnonymousNick() {
        let rnd = Int(arc4random_uniform(99999))
        self.currentNick = rnd
        self.send("NICK", destination: "justinfan\(self.currentNick)", message: nil)
    }
    
    func joinTwitchChannel(channel : TwitchChannel) {
        self.send("JOIN", destination: "#"+channel.name, message: nil)
    }
    
    override func send(command: String , destination: String?, message: String?) {
        super.send(command, destination: destination, message: message)
    }
    
    override func receive( prefix: String?, command: String , destination: String?, message: String?) {
        let handler = commandHandlers[command]
        if handler != nil
        {
            handler!.respond(self, prefix: prefix, destination: destination , message: message)
        }
        else {
            recieveTextCallback?(prefix: prefix, command: command, destination: destination, message: message)
        }
    }
    
    override func doLoop() {
        if !loop
        {
            NSLog("CHAT LOOP HALTED")
            return
        }
        super.doLoop()
        loopTimer = NSTimer.scheduledTimerWithTimeInterval(0.1 , target: self, selector: "doLoop", userInfo: nil, repeats: false)
        loopTimer!.tolerance = 0.1
    }
}

class TwitchChatIRCDelegate_433: IRCHandlerDelegate {
    func respond( target: IRCHandlerBase , prefix: String? , destination: String? , message: String? )
    {
        let twitchTarget = target as! TwitchChatHandler
        if(twitchTarget.isAnonymous){
            twitchTarget.acquireNewAnonymousNick()
        }
        else {
            if target.currentNick < (target.genericCredentials!.1.count - 1)
            {
                target.currentNick++
                target.send("NICK", destination: target.genericCredentials!.1[target.currentNick], message: nil)
            }
        }
    }
}

class TwitchChatIRCDelegate_466: IRCHandlerDelegate {
    func respond( target: IRCHandlerBase , prefix: String? , destination: String? , message: String? )
    {
        target.send("QUIT", destination: nil , message: "Error 466")
        target.disconnect()
        exit(EXIT_FAILURE)
    }
}

class TwitchChatIRCDelegate_PING: IRCHandlerDelegate {
    func respond( target: IRCHandlerBase , prefix: String? , destination: String? , message: String? )
    {
        target.send("PONG", destination: nil , message: message)
    }
}

