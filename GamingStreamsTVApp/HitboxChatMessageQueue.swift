//
//  HitboxChatMessageQueue.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

protocol HitboxChatMessageQueueDelegate {
    func handleProcessedAttributedString(message: NSAttributedString)
}

class HitboxChatMessageQueue {
    let opQueue : dispatch_queue_t
    var processTimer : dispatch_source_t?
    var timerPaused : Bool = true
    let delegate : HitboxChatMessageQueueDelegate
    let messageQueue : Queue<String>
    let mqMutex : dispatch_semaphore_t
    
    init(delegate : HitboxChatMessageQueueDelegate) {
        self.mqMutex = dispatch_semaphore_create(1)
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
        self.opQueue = dispatch_queue_create("com.hitbox.chatmq", queueAttr)
        self.delegate = delegate
        self.messageQueue = Queue<String>()
    }
    
    func addNewMessage(message : String) {
        // For the data integrity - multiple threads can be accessing at the same time
        dispatch_semaphore_wait(self.mqMutex, DISPATCH_TIME_FOREVER)
        messageQueue.offer(message)
        dispatch_semaphore_signal(self.mqMutex)
        
        if processTimer == nil || self.timerPaused {
            self.startProcessing()
        }
    }
    
    func processAvailableMessages() {
        var messagesArray = [String]()
        // For data integrity - We do not want any thread adding messages as
        // we are polling from the queue
        dispatch_semaphore_wait(self.mqMutex, DISPATCH_TIME_FOREVER)
        while(true){
            if let message = self.messageQueue.poll() {
                messagesArray.append(message)
            }
            else {
                break
            }
        }
        dispatch_semaphore_signal(self.mqMutex)
        
        // We stop if there's not message to process, it will be reactivated when
        // we recieve a new message
        if messagesArray.count == 0 {
            self.stopProcessing()
            return
        }
        
        //TODO: Process messages
        
    }
    
    func startProcessing() {
        if self.processTimer == nil && self.timerPaused {
            self.timerPaused = false
            self.processTimer = ConcurrencyHelpers.createDispatchTimer((1 * NSEC_PER_SEC)/2, leeway: (1 * NSEC_PER_SEC)/2, queue: opQueue, block: {
                self.processAvailableMessages()
            })
        }
        else if self.processTimer != nil && self.timerPaused {
            self.timerPaused = false
            dispatch_resume(self.processTimer!)
        }
    }
    
    func stopProcessing() {
        if processTimer != nil && !self.timerPaused {
            dispatch_suspend(self.processTimer!)
            self.timerPaused = true
        }
    }
    
    private func getAttributedStringForMessage(message : TwitchChatMessage) -> NSAttributedString {
        return NSAttributedString()
    }

}