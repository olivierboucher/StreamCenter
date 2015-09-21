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
    
    init() {
        super.init(host: "irc.twitch.tv", port: 6667, useSSL: false)
        
        //These commands use customized command handlers
        commandHandlers["PRIVMSG"] = TwitchCharIRCDelegate_Message()
        
        //Theses commands use base command handlers
        commandHandlers["PING"] = TwitchChatIRCDelegate_PING()
        //Errors
        commandHandlers["433"] = TwitchChatIRCDelegate_433()
        commandHandlers["466"] = TwitchChatIRCDelegate_466()
    }
    
    func anonymousConnect() {
        isAnonymous = true
        super.connect()
        self.acquireNewAnonymousNick()
    }
    
    func acquireNewAnonymousNick() {
        let rnd = Int(arc4random_uniform(99999))
        self.currentNick = rnd
        self.send("NICK", destination: "justinfan\(self.currentNick)", message: nil)
        //Enable Twitch Emotes metadata
        self.send("CAP", destination: "REQ", message: "twitch.tv/tags")
    }
    
    func joinTwitchChannel(channel : TwitchChannel) {
        self.send("JOIN", destination: "#"+channel.name, message: nil)
    }
    
    override func doLoop() {
        if !loop
        {
            NSLog("CHAT LOOP HALTED")
            return
        }
        super.doLoop()
        loopTimer = NSTimer.scheduledTimerWithTimeInterval(1 , target: self, selector: "doLoop", userInfo: nil, repeats: false)
        loopTimer?.tolerance = 1
    }
}


class TwitchCharIRCDelegate_Message : IRCHandlerDelegate {
    func respond(target: IRCHandlerBase, prefix: String?, destination: String?, message: String?, metadata : String?) {
        //NSLog("Prefix: \(prefix) | Deestination: \(destination) | Message: \(message)")
        if let safePrefix = prefix {
            if let safeMessage = message {
                if let safeMetadata = metadata {
                    let wrappedMessage = TwitchChatMessage(rawMessage: safeMessage, rawSender: safePrefix, metadata: safeMetadata)
                }
            }
        }
    }
}

class TwitchChatIRCDelegate_433: IRCHandlerDelegate {
    func respond(target: IRCHandlerBase, prefix: String?, destination: String?, message: String?, metadata : String?) {
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
    func respond(target: IRCHandlerBase, prefix: String?, destination: String?, message: String?, metadata : String?) {
        target.send("QUIT", destination: nil , message: "Error 466")
        target.disconnect()
        exit(EXIT_FAILURE)
    }
}

class TwitchChatIRCDelegate_PING: IRCHandlerDelegate {
    func respond(target: IRCHandlerBase, prefix: String?, destination: String?, message: String?, metadata : String?) {
        target.send("PONG", destination: nil , message: message)
    }
}