//
//  IRCMessage.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-18.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

struct IRCMessage {
    let sender : String?
    let user : String?
    let host : String?
    let command : String?
    let intentOrTags : [String : String]
    let parameters : [String]
}