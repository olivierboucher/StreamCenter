//
//  TokenHelper.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class TokenHelper: NSObject {
    
    static let TWITCH_SERVICE = "com.StreamCenter.Twitch.SERVICE"
    static let TWITCH_TOKEN_KEY = "com.StreamCenter.Twitch.TOKEN_KEY"
    
    static func removeTwitchToken() {
        let keychain = Keychain(service: TokenHelper.TWITCH_SERVICE)
        do {
            try keychain.remove(TokenHelper.TWITCH_TOKEN_KEY)
        } catch {
            print("error removing twitch token: \(error)")
        }
    }
    
    static func storeTwitchToken(token: String) {
        let keychain = Keychain(service: TokenHelper.TWITCH_SERVICE)
        keychain[TokenHelper.TWITCH_TOKEN_KEY] = token
    }
    
    static func getTwitchToken() -> String? {
        let keychain = Keychain(service: TokenHelper.TWITCH_SERVICE)
        return keychain[TokenHelper.TWITCH_TOKEN_KEY]
    }

}
