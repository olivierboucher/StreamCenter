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
    var processTimer : dispatch_source_t?
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
    
    func processAvailableMessages() {
        
    }
    
    func startProcessing() {
        processTimer = ConcurrencyHelpers.createDispatchTimer((1 * NSEC_PER_SEC)/2, leeway: (1 * NSEC_PER_SEC)/2, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block: {
            self.processAvailableMessages()
        })
    }
    
    func stopProcessing() {
        if processTimer != nil {
            dispatch_suspend(self.processTimer!)
        }
    }
    
}