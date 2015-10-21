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
    
    
    init(frame: CGRect, socketURL: NSURL, channel: HitboxMedia) {
        self.channel = channel
        super.init(frame: frame)
        
        self.chatMgr = HitboxChatManager(consumer: self, url: socketURL)
        
        self.backgroundColor = "#2E2E2E".toUIColorFromHex()
        
        let topLayer = CATextLayerVC()
        topLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 75)
        topLayer.foregroundColor = UIColor.whiteColor().CGColor
        topLayer.backgroundColor = "#555555".toUIColorFromHex()?.CGColor
        topLayer.alignmentMode = kCAAlignmentCenter
        topLayer.font = CGFontCreateWithFontName(UIFont.systemFontOfSize(30).fontName as NSString)
        topLayer.fontSize = 30
        topLayer.contentsScale = UIScreen.mainScreen().scale
        topLayer.string = "#" + self.channel.name
        topLayer.zPosition = 999999999
        
        let shadowPath = UIBezierPath.init(rect: CGRect(x: 0, y: topLayer.frame.height, width: self.bounds.width, height: 1))
        
        topLayer.masksToBounds = false
        topLayer.shadowColor = "#333333".toUIColorFromHex()?.CGColor
        topLayer.shadowOffset = CGSize(width: 0, height: 0.5)
        topLayer.shadowOpacity = 0.5
        topLayer.shadowPath = shadowPath.CGPath
        
        self.layer.addSublayer(topLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.channel = nil
        self.chatMgr = nil
        super.init(coder: aDecoder)
    }
    
    
    func startDisplayingMessages() {
        self.shouldConsume = true
        self.chatMgr!.connectAnonymously(channel.name)
    }
    
    func stopDisplayingMessages() {
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