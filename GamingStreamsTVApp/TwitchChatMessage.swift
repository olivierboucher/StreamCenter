//
//  TwitchChatMessage.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchChatMessage {
    var rawSender : String
    var rawMessage : String
    var metadata : String
    
    init(rawMessage : String, rawSender : String, metadata : String) {
        self.rawMessage = rawMessage
        self.rawSender = rawSender
        self.metadata = metadata
    }
}