//
//  TwitchChatMessageQueue.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchChatMessageQueue {
    //Queue
    let messageQueue : NSQueue<TwitchChatMessage>
    //Cached emotes
    let cachedEmotes : NSMutableDictionary
    
    
    init() {
        messageQueue = NSQueue<TwitchChatMessage>()
        cachedEmotes = NSMutableDictionary()
    }
    
    func addNewMessage(message : TwitchChatMessage) {
        messageQueue.push(message)
    }
    
}