//
//  TwitchChatMessage.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchChatMessage {
    let rawSender : String
    let rawMessage : String
    let rawMetadata : String
    
    var emotes : Dictionary<String, [Range<Int>]> = Dictionary<String, [Range<Int>]>()
    
    init(rawMessage : String, rawSender : String, metadata : String) {
        self.rawMessage = rawMessage
        self.rawSender = rawSender
        self.rawMetadata = metadata
    }
}