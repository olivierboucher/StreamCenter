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
    func handleNewEmoteDownloaded(id: String, data : NSData)
}

class TwitchChatMessageQueue {
    let opQueue : dispatch_queue_t
    var processTimer : dispatch_source_t?
    let delegate : TwitchChatMessageQueueDelegate
    let messageQueue : NSQueue<TwitchChatMessage>
    let mqMutex : dispatch_semaphore_t
    let cachedEmotes : NSMutableDictionary
    
    
    init(delegate : TwitchChatMessageQueueDelegate) {
        self.mqMutex = dispatch_semaphore_create(1)
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0)
        self.opQueue = dispatch_queue_create("com.twitch.chatmq", queueAttr)
        self.delegate = delegate
        self.messageQueue = NSQueue<TwitchChatMessage>()
        self.cachedEmotes = NSMutableDictionary()
    }
    
    func addNewMessage(message : TwitchChatMessage) {
        dispatch_semaphore_wait(self.mqMutex, DISPATCH_TIME_FOREVER);
        messageQueue.offer(message)
        dispatch_semaphore_signal(self.mqMutex)
        
        if processTimer == nil {
            self.startProcessing()
        }
    }
    
    func processAvailableMessages() {
        var messagesArray = Array<TwitchChatMessage>()
        dispatch_semaphore_wait(self.mqMutex, DISPATCH_TIME_FOREVER);
        while(true){
            if let message = self.messageQueue.poll() as! TwitchChatMessage? {
                messagesArray.append(message)
            }
            else {
                break
            }
        }
        dispatch_semaphore_signal(self.mqMutex)
        
        if messagesArray.count == 0 {
            self.stopProcessing()
            return
        }
        
        for message : TwitchChatMessage in messagesArray {
            let metaByLine = message.rawMetadata.componentsSeparatedByString(";");
            
            for singleMeta in metaByLine {
                // key = [0] and value = [1]
                let keyValue = singleMeta.componentsSeparatedByString("=")
                
                if keyValue[0] == "emotes" && !keyValue[1].isEmpty  {
                    let emotesById = keyValue[1].containsString("/") ? keyValue[1].componentsSeparatedByString("/") : [keyValue[1]]
                    
                    for emote in emotesById {
                        // id = [0] and values = [1]
                        let rangesById = emote.componentsSeparatedByString(":")
                        let emoteId = rangesById[0]
                        let emoteRawRanges = rangesById[1].componentsSeparatedByString(",")
                        
                        for rawRange in emoteRawRanges {
                            let startEnd = rawRange.componentsSeparatedByString("-")
                            let start = Int(startEnd[0])
                            let end = Int(startEnd[1])
                            
                            let range = Range<Int>(start: start!, end: end!)
                            if message.emotes[emoteId] == nil {
                                message.emotes[emoteId] = [range]
                            }
                            else {
                                message.emotes[emoteId]?.append(range)
                            }
                            
                        }
                        
                        //If emote not in cache, request download
                    }
                }
            }
            
            self.delegate.handleProcessedTwitchMessage(message)
        }
        
    }
    
    func startProcessing() {
        self.processTimer = ConcurrencyHelpers.createDispatchTimer((1 * NSEC_PER_SEC)/2, leeway: (1 * NSEC_PER_SEC)/2, queue: opQueue, block: {
            self.processAvailableMessages()
        })
    }
    
    func stopProcessing() {
        if processTimer != nil {
            dispatch_suspend(self.processTimer!)
        }
    }
    
}