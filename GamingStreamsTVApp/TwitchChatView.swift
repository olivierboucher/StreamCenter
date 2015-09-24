//
//  TwitchChatView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-23.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//
import UIKit
import Foundation


class TwitchChatView : UIView, TwitchChatHandlerConsumer {
    let channel : TwitchChannel?
    let chatHandler = TwitchChatHandler()
    var shouldConsume = false
    var messageViews = Array<TwitchChatMessageView>()
    
    init(frame: CGRect, channel: TwitchChannel) {
        self.channel = channel
        super.init(frame: frame)
        
        self.chatHandler.consumer = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.channel = nil
        super.init(coder: aDecoder)
    }
    
    
    func startDisplayingMessages() {
        self.shouldConsume = true
        self.chatHandler.anonymousConnect()
        self.chatHandler.startLoop()
        self.chatHandler.joinTwitchChannel(self.channel!)
    }
    
    func stopDisplayingMessages() {
        self.shouldConsume = false
        self.chatHandler.stopLoop()
        self.chatHandler.disconnect()
    }
    
    func messageReadyForDisplay(message: TwitchChatMessage) {
        if self.shouldConsume {
            dispatch_async(dispatch_get_main_queue(),{
                let view = TwitchChatMessageView(message: message, width: self.bounds.width-20, position: CGPoint(x: 10, y: 0))
                
                var newFrame = view.frame
                newFrame.origin.y = self.frame.height - view.frame.height
                
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
                
                self.addSubview(view)
            })
        }
    }
}