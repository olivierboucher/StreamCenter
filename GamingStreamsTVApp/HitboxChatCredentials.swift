//
//  HitboxChatCredentials.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-20.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

struct HitboxChatCredentials {
    static func anonymous() -> HitboxChatCredentials {
        return HitboxChatCredentials(username: nil, token: nil)
    }
    
    let username : String?
    let token : String?
    
    func getJoinMessage(channel : String) -> String? {
        guard let username = username as String!, let token = token as String! else {
            let msg : JSON = [
                "name" : "message",
                "args" : [
                    [
                        "method" : "joinChannel",
                        "params" : [
                            "channel" : channel,
                            "isAdmin" : false
                        ]
                    ]
                ]
            ]
            
            return msg.string
        }
        
        let msg : JSON = [
            "name" : "message",
            "args" : [
                [
                    "method" : "joinChannel",
                    "params" : [
                        "channel"   : channel,
                        "name"      : username,
                        "token"     : token,
                        "isAdmin"   : false
                    ]
                ]
            ]
        ]
        
        return msg.string
    }
    
}