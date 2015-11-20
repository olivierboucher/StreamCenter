//
//  TwitchChatMessageQueue.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.

import Alamofire
import UIKit
import Foundation

protocol TwitchChatMessageQueueDelegate {
    func handleProcessedAttributedString(message: NSAttributedString)
    func handleNewEmoteDownloaded(id: String, data : NSData)
    func hasEmoteInCache(id: String) -> Bool
    func getEmoteDataFromCache(id: String) -> NSData?
}

class TwitchChatMessageQueue {
    let opQueue : dispatch_queue_t
    var processTimer : dispatch_source_t?
    var timerPaused : Bool = true
    let delegate : TwitchChatMessageQueueDelegate
    let messageQueue : Queue<IRCMessage>
    let mqMutex : dispatch_semaphore_t
    
    
    init(delegate : TwitchChatMessageQueueDelegate) {
        self.mqMutex = dispatch_semaphore_create(1)
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
        self.opQueue = dispatch_queue_create("com.twitch.chatmq", queueAttr)
        self.delegate = delegate
        self.messageQueue = Queue<IRCMessage>()
    }
    
    func addNewMessage(message : IRCMessage) {
        // For the data integrity - multiple threads can be accessing at the same time
        dispatch_semaphore_wait(self.mqMutex, DISPATCH_TIME_FOREVER)
        messageQueue.offer(message)
        dispatch_semaphore_signal(self.mqMutex)
        
        if processTimer == nil || self.timerPaused {
            self.startProcessing()
        }
    }
    
    func processAvailableMessages() {
        var messagesArray = [IRCMessage]()
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
        
        for ircMessage : IRCMessage in messagesArray {
            if let twitchMessage = ircMessage.toTwitchChatMessage() {
                let downloadGroup = dispatch_group_create()
                for emote in twitchMessage.emotes {
                    if !self.delegate.hasEmoteInCache(emote.0){
                        dispatch_group_enter(downloadGroup)
                        Alamofire.request(.GET, TwitchApi.getEmoteUrlStringFromId(emote.0)).response() {
                            (_, _, data, error) in
                            if error != nil {
                                Logger.Error("Could not download emote image for id: \(emote.0)")
                            }
                            else {
                                self.delegate.handleNewEmoteDownloaded(emote.0, data: data!)
                            }
                            dispatch_group_leave(downloadGroup)
                        }
                    }
                }
                dispatch_group_wait(downloadGroup, DISPATCH_TIME_FOREVER)
                
                delegate.handleProcessedAttributedString(self.getAttributedStringForMessage(twitchMessage))
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
    
    private func getAttributedStringForMessage(message : TwitchChatMessage) -> NSAttributedString {
        
        let attrMsg = NSMutableAttributedString(string: message.message)
        
        for (emoteID, emote) in message.emotes {
            let attachment = NSTextAttachment()
            guard let emoteData = self.delegate.getEmoteDataFromCache(emoteID) else {
                Logger.Warning("Could not find \(emoteID) in emote cache")
                continue
            }
            let emoteImage = UIImage(data: emoteData)
            attachment.image = emoteImage
            let emoteString = NSAttributedString(attachment: attachment)

            while true {
                let range = attrMsg.mutableString.rangeOfString(emote)
                
                guard range.location != NSNotFound else {
                    break
                }
                
                attrMsg.replaceCharactersInRange(range, withAttributedString: emoteString)
            }
        }
        
        attrMsg.insertAttributedString(NSAttributedString(string: "\(message.senderName): "), atIndex: 0)
        attrMsg.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#AAAAAA"), range: NSMakeRange(0, attrMsg.length))
        attrMsg.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: message.senderDisplayColor), range: NSMakeRange(0, message.senderName.characters.count))
        attrMsg.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(18), range: NSMakeRange(0, attrMsg.length))
        
        
        return attrMsg
    }
}