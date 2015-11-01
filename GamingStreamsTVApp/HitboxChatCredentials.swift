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
    
    func getJoinMessage(channel : String) -> String {
        guard let username = username, let token = token else {
            return "5:::{\"name\":\"message\",\"args\":[{\"method\":\"joinChannel\",\"params\":{\"channel\":\"\(channel.lowercaseString)\",\"name\":\"unknown\",\"token\":\"\",\"isAdmin\":false}}]}"
        }
        
        return "5:::{\"name\":\"message\",\"args\":[{\"method\":\"joinChannel\",\"params\":{\"channel\":\"\(channel.lowercaseString)\",\"name\":\"\(username)\",\"token\":\"\(token)\",\"isAdmin\":false}}]}"
    }
    
}