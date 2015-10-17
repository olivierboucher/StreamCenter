//
//  TwitchChatMessage.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.

import Foundation

class TwitchChatMessage {
    //Raw Data
    let rawSender : String
    let rawMessage : String
    let rawMetadata : String
    //Clean data
    var sender : String?
    var emotes = [String : [NSRange]]()
    var senderDisplayColor : String?
    //Processed message
    var completeMessage : NSAttributedString?
    
    init(rawMessage : String, rawSender : String, metadata : String) {
        self.rawMessage = rawMessage
        self.rawSender = rawSender
        self.rawMetadata = metadata
    }
}