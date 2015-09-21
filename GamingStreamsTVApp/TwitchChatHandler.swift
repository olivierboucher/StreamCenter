//
//  TwitchChatHandler.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-19.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchChatHandler : IRCHandlerBase, TwitchChatMessageQueueDelegate {
    var opQueue : dispatch_queue_t
    var loopTimer: dispatch_source_t?
    var isAnonymous : Bool = false
    var messageQueue : TwitchChatMessageQueue?
    var imagesDictionnary : [String : NSData]? //Dictionnary that holds all the emotes (Acts as cache)
    
    init() {
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
        opQueue = dispatch_queue_create("com.twitch.chathandler", queueAttr)
        
        super.init(host: "irc.twitch.tv", port: 6667, useSSL: false)
        
        self.messageQueue = TwitchChatMessageQueue(delegate: self)
        
        commandHandlers["PRIVMSG"] = TwitchChatIRCDelegate_Message()
        commandHandlers["PING"] = TwitchChatIRCDelegate_PING()
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
    
    func startLoop() {
        loopTimer = ConcurrencyHelpers.createDispatchTimer((1 * NSEC_PER_SEC)/2, leeway: (1 * NSEC_PER_SEC)/3, queue: opQueue, block: {
            super.doLoop()
        })
    }
    func stopLoop() {
        if(self.loopTimer != nil) {
            dispatch_suspend(self.loopTimer!)
        }
    }
    /*
        DELEGATE METHODS
    */
    func handleProcessedTwitchMessage(message: TwitchChatMessage) {
        if message.emotes.count != 0 {
            let lllll = 0
        }
    }
    func handleNewEmoteDownloaded(id: String, data : NSData) {
        
    }
}


private class TwitchChatIRCDelegate_Message : IRCHandlerDelegate {
    func respond(target: IRCHandlerBase, prefix: String?, destination: String?, message: String?, metadata : String?) {
        let twitchTarget = target as! TwitchChatHandler
        if let safePrefix = prefix {
            if let safeMessage = message {
                if let safeMetadata = metadata {
                    let wrappedMessage = TwitchChatMessage(rawMessage: safeMessage, rawSender: safePrefix, metadata: safeMetadata)
                    twitchTarget.messageQueue!.addNewMessage(wrappedMessage)
                }
            }
        }
    }
}

private class TwitchChatIRCDelegate_433: IRCHandlerDelegate {
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

private class TwitchChatIRCDelegate_466: IRCHandlerDelegate {
    func respond(target: IRCHandlerBase, prefix: String?, destination: String?, message: String?, metadata : String?) {
        target.send("QUIT", destination: nil , message: "Error 466")
        target.disconnect()
        exit(EXIT_FAILURE)
    }
}

private class TwitchChatIRCDelegate_PING: IRCHandlerDelegate {
    func respond(target: IRCHandlerBase, prefix: String?, destination: String?, message: String?, metadata : String?) {
        target.send("PONG", destination: nil , message: message)
    }
}