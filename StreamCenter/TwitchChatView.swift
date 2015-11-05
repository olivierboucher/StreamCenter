//
//  TwitchChatView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-23.

import UIKit
import Foundation


class TwitchChatView : UIView {
    let channel : TwitchChannel!
    var chatMgr : TwitchChatManager? = nil
    var shouldConsume = false
    var messageViews = [ChatMessageView]()
    
    
    init(frame: CGRect, channel: TwitchChannel) {
        self.channel = channel
        super.init(frame: frame)
        
        self.chatMgr = TwitchChatManager(consumer: self)
        
        self.backgroundColor = UIColor(hexString: "#19191F")
        
        let topView = ChatTopView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 75), title: "#\(self.channel.name)")
        self.addSubview(topView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.channel = nil
        self.chatMgr = nil
        super.init(coder: aDecoder)
    }
    
    
    func startDisplayingMessages() {
        Logger.Debug("Attempting to connect and display chat messages")
        self.shouldConsume = true
        self.chatMgr!.connectAnonymously()
        self.chatMgr!.joinTwitchChannel(self.channel)
    }
    
    func stopDisplayingMessages() {
        Logger.Debug("Disconnecting from chat")
        self.shouldConsume = false
        self.chatMgr!.disconnect()
    }
    
}

extension TwitchChatView : ChatManagerConsumer {
    func messageReadyForDisplay(message: NSAttributedString) {
        if self.shouldConsume {
            dispatch_async(dispatch_get_main_queue(),{
                let view = ChatMessageView(message: message, width: self.bounds.width-40, position: CGPoint(x: 20, y: 0))
                
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
                
                self.insertSubview(view, atIndex: 0)
            })
        }
    }
}