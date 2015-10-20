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
}