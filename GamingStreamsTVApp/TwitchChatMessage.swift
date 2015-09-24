//
//  TwitchChatMessage.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchChatMessage {
    //Raw Data
    let rawSender : String
    let rawMessage : String
    let rawMetadata : String
    //Clean data
    var sender : String?
    var emotes : Dictionary<String, [NSRange]> = Dictionary<String, [NSRange]>()
    //Processed message
    var completeMessage : NSAttributedString?
    
    init(rawMessage : String, rawSender : String, metadata : String) {
        self.rawMessage = rawMessage
        self.rawSender = rawSender
        self.rawMetadata = metadata
    }
}