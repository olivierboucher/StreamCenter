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
    
    static let HITBOX_SERVICE = "com.StreamCenter.Hitbox.SERVICE"
    static let HITBOX_TOKEN_KEY = "com.StreamCenter.Hitbox.TOKEN_KEY"
    
    static func storeTwitchToken(token: String) {
        let keychain = Keychain(service: TokenHelper.TWITCH_SERVICE)
        keychain[TokenHelper.TWITCH_TOKEN_KEY] = token
    }
    
    static func getTwitchToken() -> String? {
        let keychain = Keychain(service: TokenHelper.TWITCH_SERVICE)
        return keychain[TokenHelper.TWITCH_TOKEN_KEY]
    }
    
    static func removeTwitchToken() {
        let keychain = Keychain(service: TokenHelper.TWITCH_SERVICE)
        do {
            try keychain.remove(TokenHelper.TWITCH_TOKEN_KEY)
        } catch {
            print("error removing twitch token: \(error)")
        }
    }
    
    static func storeHitboxToken(token: String) {
        let keychain = Keychain(service: TokenHelper.HITBOX_SERVICE)
        keychain[TokenHelper.HITBOX_TOKEN_KEY] = token
    }
    
    static func getHitboxToken() -> String? {
        let keychain = Keychain(service: TokenHelper.HITBOX_SERVICE)
        return keychain[TokenHelper.HITBOX_TOKEN_KEY]
    }
    
    static func removeHitboxToken() {
        let keychain = Keychain(service: TokenHelper.HITBOX_SERVICE)
        do {
            try keychain.remove(TokenHelper.HITBOX_TOKEN_KEY)
        } catch {
            print("error removing hitbox token: \(error)")
        }
    }

}
