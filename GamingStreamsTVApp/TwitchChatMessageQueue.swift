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
    let opQueue : dispatch_queue_t
    var processTimer : dispatch_source_t?
    let delegate : TwitchChatMessageQueueDelegate
    let messageQueue : NSQueue<TwitchChatMessage>
    let cachedEmotes : NSMutableDictionary
    
    
    init(delegate : TwitchChatMessageQueueDelegate) {
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 1)
        opQueue = dispatch_queue_create("com.twitch.chatmq", queueAttr)
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