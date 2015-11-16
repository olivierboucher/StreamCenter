//
//  HitboxChatMessageQueue.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import UIKit

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
        // we receive a new message
        if messagesArray.count == 0 {
            self.stopProcessing()
            return
        }
        
        for message in messagesArray {
            //We need to remove ":::5"
            guard let data = message[4..<message.characters.count].dataUsingEncoding(NSUTF8StringEncoding) else {
                Logger.Warning("Could not remove the first 4 characters from the message\nThe message is probably corrupted\n\(message)")
                return
            }
            
            do {
                guard let msgJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String : AnyObject] else {
                    Logger.Error("JSON object could not be casted as [String : AnyObject]")
                    return
                }
                
                if let name = msgJSON["name"] as? String, rawArgs = msgJSON["args"] as? [String] where name == "message" {
                    
                    guard let argsData = rawArgs[0].dataUsingEncoding(NSUTF8StringEncoding), args = try NSJSONSerialization.JSONObjectWithData(argsData, options: .AllowFragments) as? [String : AnyObject] else {
                        Logger.Error("JSON object could not be casted as [String : AnyObject]")
                        return
                    }
                    
                    if let method = args["method"] as? String {
                        switch method {
                        case "chatMsg" :
                            if let params = args["params"] as? [String : AnyObject] {
                                if let senderName = params["name"] as? String, text = params["text"] as? String, senderColor = params["nameColor"] as? String {
                                    
                                    let sanitizedText = text.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                                    let attrString = getAttributedStringForMessage(HitboxChatMessage(senderName: senderName, senderDisplayColor: senderColor, message: sanitizedText))
                                    delegate.handleProcessedAttributedString(attrString)
                                }
                            }
                            break
                        default:
                            break
                        }
                    }
                }
            } catch {
                Logger.Error("Could not process message, JSON deserialization failed")
            }
        }  
    }
    
    func startProcessing() {
        if self.processTimer == nil && self.timerPaused {
            Logger.Debug("Creating a new process timer")
            self.timerPaused = false
            self.processTimer = ConcurrencyHelpers.createDispatchTimer((1 * NSEC_PER_SEC)/2, leeway: (1 * NSEC_PER_SEC)/2, queue: opQueue, block: {
                self.processAvailableMessages()
            })
            return
        }
        else if self.processTimer != nil && self.timerPaused {
            Logger.Debug("Resuming existing process timer")
            self.timerPaused = false
            dispatch_resume(self.processTimer!)
            return
        }
        Logger.Error("Conditions not met, could not start processing")
    }
    
    func stopProcessing() {
        if processTimer != nil && !self.timerPaused {
            Logger.Debug("Suspending process timer")
            dispatch_suspend(self.processTimer!)
            self.timerPaused = true
            return
        }
        Logger.Error("Could not stop processing since timer is either nil or already paused")
    }
    
    private func getAttributedStringForMessage(message : HitboxChatMessage) -> NSAttributedString {
        let attrMsg = NSMutableAttributedString(string: "\(message.senderName): \(message.message)")
        
        let color = UIColor(hexString: "#\(message.senderDisplayColor)")
    
        attrMsg.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(0, attrMsg.length))
        attrMsg.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, message.senderName.characters.count))
        attrMsg.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(18), range: NSMakeRange(0, attrMsg.length))
        
        return attrMsg
    }

}