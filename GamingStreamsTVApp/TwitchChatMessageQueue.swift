//
//  TwitchChatMessageQueue.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.

import Alamofire
import UIKit
import Foundation

protocol TwitchChatMessageQueueDelegate {
    func handleProcessedTwitchMessage(message: TwitchChatMessage)
    func handleNewEmoteDownloaded(id: String, data : NSData)
    func hasEmoteInCache(id: String) -> Bool
    func getEmoteDataFromCache(id: String) -> NSData?
}

class TwitchChatMessageQueue {
    let opQueue : dispatch_queue_t
    var processTimer : dispatch_source_t?
    var timerPaused : Bool = true
    let delegate : TwitchChatMessageQueueDelegate
    let messageQueue : NSQueue<TwitchChatMessage>
    let mqMutex : dispatch_semaphore_t
    
    
    init(delegate : TwitchChatMessageQueueDelegate) {
        self.mqMutex = dispatch_semaphore_create(1)
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
        self.opQueue = dispatch_queue_create("com.twitch.chatmq", queueAttr)
        self.delegate = delegate
        self.messageQueue = NSQueue<TwitchChatMessage>()
    }
    
    func addNewMessage(message : TwitchChatMessage) {
        // For the data integrity - multiple threads can be accessing at the same time
        dispatch_semaphore_wait(self.mqMutex, DISPATCH_TIME_FOREVER)
        messageQueue.offer(message)
        dispatch_semaphore_signal(self.mqMutex)
        
        if processTimer == nil || self.timerPaused {
            self.startProcessing()
        }
    }
    
    func processAvailableMessages() {
        var messagesArray = [TwitchChatMessage]()
        // For data integrity - We do not want any thread adding messages as
        // we are polling from the queue
        dispatch_semaphore_wait(self.mqMutex, DISPATCH_TIME_FOREVER)
        while(true){
            if let message = self.messageQueue.poll() as! TwitchChatMessage? {
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
        
        for message : TwitchChatMessage in messagesArray {
            let metaByLine = message.rawMetadata.componentsSeparatedByString(";")
            
            for singleMeta in metaByLine {
                // key = [0] and value = [1]
                let keyValue = singleMeta.componentsSeparatedByString("=")
                
                if keyValue[0] == "emotes" && !keyValue[1].isEmpty  {
                    let emotesById = keyValue[1].containsString("/") ? keyValue[1].componentsSeparatedByString("/") : [keyValue[1]]
                    
                    let downloadGroup = dispatch_group_create()
                    
                    for emote in emotesById {
                        // id = [0] and values = [1]
                        let rangesById = emote.componentsSeparatedByString(":")
                        let emoteId = rangesById[0]
                        let emoteRawRanges = rangesById[1].componentsSeparatedByString(",")
                        
                        for rawRange in emoteRawRanges {
                            let startEnd = rawRange.componentsSeparatedByString("-")
                            let start = Int(startEnd[0])
                            let end = Int(startEnd[1])
                            
                            let range = NSMakeRange(start!, end! - start! + 1)
                            if message.emotes[emoteId] == nil {
                                message.emotes[emoteId] = [range]
                            }
                            else {
                                message.emotes[emoteId]?.append(range)
                            }
                            
                        }

                        if !self.delegate.hasEmoteInCache(emoteId){
                            dispatch_group_enter(downloadGroup)
                            Alamofire.request(.GET, TwitchApi.getEmoteUrlStringFromId(emoteId)).response() {
                                (_, _, data, error) in
                                if error != nil {
                                    NSLog("Error downloading emote image")
                                }
                                else {
                                    self.delegate.handleNewEmoteDownloaded(emoteId, data: data!)
                                }
                                dispatch_group_leave(downloadGroup)
                            }
                        }
                    }
                    dispatch_group_wait(downloadGroup, DISPATCH_TIME_FOREVER)
                }
                else if keyValue[0] == "display-name" && !keyValue[1].isEmpty  {
                    message.sender = self.sanitizedIRCString(keyValue[1])
                }
                else if keyValue[0] == "@color" && !keyValue[1].isEmpty  {
                    message.senderDisplayColor = keyValue[1]
                }
            }
            
            //SAFE CHECKS
            if message.sender == nil {
                message.sender = message.rawSender.componentsSeparatedByString("!")[0]
            }
            
            if message.senderDisplayColor == nil {
                message.senderDisplayColor = "#555555"
            }
            
            message.completeMessage = self.getAttributedStringForMessage(message)
            
            self.delegate.handleProcessedTwitchMessage(message)
        }
        
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
        
        let attrMsg = NSMutableAttributedString(string: message.sender! + ": " + message.rawMessage)
        
        
        if(message.emotes.count > 0) {
            var removedChars = -(message.sender!.characters.count + 2) //Because ranges are based on rawMessage
            for emote in message.emotes {
                let attachment = NSTextAttachment()
                let emoteImage = UIImage(data: self.delegate.getEmoteDataFromCache(emote.0)!)
                attachment.image = emoteImage
                
                let attachString = NSAttributedString(attachment: attachment)
                for range in emote.1{
                    var fixedRange = range
                    fixedRange.location -= removedChars
                    
                    let string = attrMsg.string
                    
                    let rmCount = string.substringWithRange(string.rangeFromNSRange(range)!).characters.count - attachString.length
                    if fixedRange.location + fixedRange.length <= attrMsg.length {
                        removedChars += rmCount
                        if attachString != "\\U0000fffc" {
                            attrMsg.replaceCharactersInRange(fixedRange, withAttributedString: attachString)
                        } else {
                            print("didn't add")
                        }
                    }
                }
            }
        }
        
        attrMsg.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(0, attrMsg.length))
        attrMsg.addAttribute(NSForegroundColorAttributeName, value: message.senderDisplayColor!.toUIColorFromHex()!, range: NSMakeRange(0, message.sender!.characters.count))
        attrMsg.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(18), range: NSMakeRange(0, attrMsg.length))
        
        return attrMsg
    }
    
    private func sanitizedIRCString(string: String) -> String {
        //https://github.com/ircv3/ircv3-specifications/blob/master/core/message-tags-3.2.md#escaping-values
        
        return string.stringByReplacingOccurrencesOfString("\\:", withString: ";")
                .stringByReplacingOccurrencesOfString("\\s", withString: "")
                .stringByReplacingOccurrencesOfString("\\\\", withString: "\\")
                .stringByReplacingOccurrencesOfString("\\r", withString: "\r")
                .stringByReplacingOccurrencesOfString("\\n", withString: "\n")
        
    }
    
}