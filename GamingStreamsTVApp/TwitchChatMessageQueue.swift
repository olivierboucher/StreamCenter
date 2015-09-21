//
//  TwitchChatMessageQueue.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

protocol TwitchChatMessageQueueDelegate {
    func handleProcessedTwitchMessage(message: TwitchChatMessage)
}

class TwitchChatMessageQueue {
    let delegate : TwitchChatMessageQueueDelegate
    let messageQueue : NSQueue<TwitchChatMessage>
    let cachedEmotes : NSMutableDictionary
    
    
    init(delegate : TwitchChatMessageQueueDelegate) {
        self.delegate = delegate
        self.messageQueue = NSQueue<TwitchChatMessage>()
        self.cachedEmotes = NSMutableDictionary()
    }
    
    func addNewMessage(message : TwitchChatMessage) {
        messageQueue.offer(message)
    }
    
}