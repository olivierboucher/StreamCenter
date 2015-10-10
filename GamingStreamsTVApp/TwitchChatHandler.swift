//
//  TwitchChatHandler.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-19.

import Foundation

protocol TwitchChatHandlerConsumer {
    func messageReadyForDisplay(message: TwitchChatMessage)
}

class TwitchChatHandler : IRCHandlerBase {
    var opQueue : dispatch_queue_t
    var loopTimer: dispatch_source_t?
    var isAnonymous : Bool = false
    var messageQueue : TwitchChatMessageQueue?
    var emotesDictionnary = [String : NSData]() //Dictionnary that holds all the emotes (Acts as cache)
    var consumer : TwitchChatHandlerConsumer?
    
    init() {
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
        opQueue = dispatch_queue_create("com.twitch.chathandler", queueAttr)
        
        super.init(host: "irc.twitch.tv", port: 6667, useSSL: false)
        
        self.messageQueue = TwitchChatMessageQueue(delegate: self)
        
        //Sets the command handlers for each command type
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
}

/////////////////////////////////////////
// MARK - TwitchChatMessageQueueDelegate
/////////////////////////////////////////

extension TwitchChatHandler : TwitchChatMessageQueueDelegate {
    
    func handleProcessedTwitchMessage(message: TwitchChatMessage) {
        self.consumer!.messageReadyForDisplay(message)
    }
    func handleNewEmoteDownloaded(id: String, data : NSData) {
        emotesDictionnary[id] = data
    }
    func hasEmoteInCache(id: String) -> Bool {
        return self.emotesDictionnary[id] != nil
    }
    func getEmoteDataFromCache(id: String) -> NSData? {
        return self.emotesDictionnary[id]
    }
}

//////////////////////////////
// MARK - IRCHandlerDelegates
//////////////////////////////

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