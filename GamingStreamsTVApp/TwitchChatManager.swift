//
//  TwitchChatManager.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-18.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchChatManager {
    
    static func generateAnonymousIRCCredentials() -> IRCCredentials {
        let rnd = Int(arc4random_uniform(99999))
        return IRCCredentials(username: nil, password: nil, nick: "justinfan\(rnd)")
    }
    
    private var connection : IRCConnection?
    private var credentials : IRCCredentials?
    private var capabilities = IRCCapabilities(capabilities: ["twitch.tv/tags"])
    private var messageQueue : TwitchChatMessageQueue?
    private var emotesDictionnary = [String : NSData]() //Dictionnary that holds all the emotes (Acts as cache)
    private var consumer : TwitchChatConsumer?
    
    init(consumer : TwitchChatConsumer) {
        self.consumer = consumer
        self.messageQueue = TwitchChatMessageQueue(delegate: self)
        connection = IRCConnection(delegate: self)

        //Command handlers
        connection!.commandHandlers["PING"] = handlePing
        connection!.commandHandlers["PRIVMSG"] = handleMsg
        connection!.commandHandlers["433"] = handle433
    }
    
    func connectAnonymously() {
        credentials = TwitchChatManager.generateAnonymousIRCCredentials()
        connection!.connect(IRCEndpoint(host: "irc.twitch.tv", port: 6667), credentials: credentials!, capabilities: capabilities)
    }
    
/////////////////////////////////////////
// MARK - Command handlers
/////////////////////////////////////////
    
    private func handlePing(sender : String?, user : String?, host : String?, command : String?, intentOrTags : [String : String], parameters : [String]) -> () {
        
    }
    
    private func handleMsg(sender : String?, user : String?, host : String?, command : String?, intentOrTags : [String : String], parameters : [String]) -> () {
        
    }
    
    private func handle433(sender : String?, user : String?, host : String?, command : String?, intentOrTags : [String : String], parameters : [String]) -> () {
        
    }
}

/////////////////////////////////////////
// MARK - TwitchChatMessageQueueDelegate
/////////////////////////////////////////

extension TwitchChatManager : TwitchChatMessageQueueDelegate {
    
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

/////////////////////////////////////////
// MARK - IRCConnectionDelegate
/////////////////////////////////////////

extension TwitchChatManager : IRCConnectionDelegate {
    func IRCConnectionDidConnect() {
        
    }
    func IRCConnectionDidDisconnect() {
        
    }
    func IRCConnectionDidNotConnect() {
        
    }
}