//
//  HitboxChatView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import UIKit

class HitboxChatView : UIView {
    let channel : HitboxMedia!
    var chatMgr : HitboxChatManager? = nil
    var shouldConsume = false
    var messageViews = [ChatMessageView]()
    let isCapableOfSendingMessages = TokenHelper.getHitboxToken() != nil
    
    
    init(frame: CGRect, socketURL: NSURL, channel: HitboxMedia, chatMessageDelegate: UITextFieldDelegate) {
        self.channel = channel
        super.init(frame: frame)
        
        self.chatMgr = HitboxChatManager(consumer: self, url: socketURL)
        
        self.backgroundColor = "#2E2E2E".toUIColorFromHex()
        
        let topView = ChatTopView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 75), title: "#\(self.channel.name)")
        self.addSubview(topView)
        
        if isCapableOfSendingMessages {
            let textField = UITextField(frame: CGRect(x: 0, y: frame.height - 60, width: frame.width, height: 60))
            textField.delegate = chatMessageDelegate
            textField.placeholder = "Enter Text"
            self.addSubview(textField)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.channel = nil
        self.chatMgr = nil
        super.init(coder: aDecoder)
    }
    
    func startDisplayingMessages() {
        Logger.Debug("Attempting to connect and display chat messages")
        self.shouldConsume = true
        self.chatMgr!.connectAnonymously(channel.name)
    }
    
    func stopDisplayingMessages() {
        Logger.Debug("Disconnecting from chat")
        self.shouldConsume = false
        self.chatMgr!.disconnect()
    }
    
}

extension HitboxChatView : ChatManagerConsumer {
    func messageReadyForDisplay(message: NSAttributedString) {
        if self.shouldConsume {
            dispatch_async(dispatch_get_main_queue(),{
                let view = ChatMessageView(message: message, width: self.bounds.width-40, position: CGPoint(x: 20, y: 0))
                
                var newFrame = view.frame
                newFrame.origin.y = self.frame.height - view.frame.height - (self.isCapableOfSendingMessages ? 60 : 0)
                
                view.frame = newFrame
                
                for messageView in self.messageViews {
                    newFrame = messageView.frame
                    newFrame.origin.y = newFrame.origin.y - view.frame.height
                    messageView.frame = newFrame
                    
                    if messageView.frame.origin.y < -100 { //Looks better than 0
                        self.messageViews.removeFirst()
                        messageView.removeFromSuperview()
                    }
                }
                self.messageViews.append(view)
                
                self.insertSubview(view, atIndex: 0)
            })
        }
    }
}