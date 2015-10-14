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
    
//    static func storeTwitchToken(token: String) {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setObject(token, forKey: TokenHelper.TWITCH_TOKEN_KEY)
//        defaults.synchronize()
//    }
//    
//    static func getTwitchToken() -> String? {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        return defaults.stringForKey(TokenHelper.TWITCH_TOKEN_KEY)
//    }
    
    static func storeTwitchToken(token: String) {
        let keychain = Keychain(service: TokenHelper.TWITCH_SERVICE)
        keychain[TokenHelper.TWITCH_TOKEN_KEY] = token
    }
    
    static func getTwitchToken() -> String? {
        let keychain = Keychain(service: TokenHelper.TWITCH_SERVICE)
        return keychain[TokenHelper.TWITCH_TOKEN_KEY]
    }

}
