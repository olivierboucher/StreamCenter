//
//  TwitchChatMessage.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.

import Foundation

struct TwitchChatMessage {
    //Raw Data
    let rawSender : String
    let rawMessage : String
    let rawIntentOrTags : [String : String]
    //Clean data
    var sender : String?
    var emotes = [String : [NSRange]]()
    var senderDisplayColor : String?
    //Processed message
    var completeMessage : NSAttributedString?
    
    init(rawMessage : String, rawSender : String, intentOrTags : [String : String]) {
        self.rawMessage = rawMessage
        self.rawSender = rawSender
        self.rawIntentOrTags = intentOrTags
    }
}