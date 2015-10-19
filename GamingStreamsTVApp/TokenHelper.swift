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
    static let TWITCH_USERNAME_KEY = "com.StreamCenter.Twitch.USERNAME_KEY"
    
    static let HITBOX_SERVICE = "com.StreamCenter.Hitbox.SERVICE"
    static let HITBOX_TOKEN_KEY = "com.StreamCenter.Hitbox.TOKEN_KEY"
    
    static func storeTwitchToken(token: String) {
        TokenHelper.putString(token, key: TWITCH_TOKEN_KEY, service: TWITCH_SERVICE)
    }
    
    static func getTwitchToken() -> String? {
        return TokenHelper.getString(TWITCH_TOKEN_KEY, forService: TWITCH_SERVICE)
    }
    
    static func storeTwitchUsername(username: String) {
        TokenHelper.putString(username, key: TWITCH_USERNAME_KEY, service: TWITCH_SERVICE)
    }
    
    static func getTwitchUsername() -> String? {
        return TokenHelper.getString(TWITCH_USERNAME_KEY, forService: TWITCH_SERVICE)
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
        TokenHelper.putString(token, key: HITBOX_TOKEN_KEY, service: HITBOX_SERVICE)
    }
    
    static func getHitboxToken() -> String? {
        return TokenHelper.getString(HITBOX_TOKEN_KEY, forService: HITBOX_SERVICE)
    }
    
    static func removeHitboxToken() {
        let keychain = Keychain(service: TokenHelper.HITBOX_SERVICE)
        do {
            try keychain.remove(TokenHelper.HITBOX_TOKEN_KEY)
        } catch {
            print("error removing hitbox token: \(error)")
        }
    }
    
    static func getString(key: String, forService service: String) -> String? {
        let keychain = Keychain(service: service)
        return keychain[key]
    }
    
    static func putString(value: String, key: String, service: String) {
        let keychain = Keychain(service: service)
        keychain[key] = value
    }

}
