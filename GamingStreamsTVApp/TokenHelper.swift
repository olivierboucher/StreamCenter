//
//  TokenHelper.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/13/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class TokenHelper: NSObject {
    
    static let TOKEN_KEY = "com.StreamCenter.TOKEN_KEY"
    
    static func storeToken(token: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(token, forKey: TokenHelper.TOKEN_KEY)
        defaults.synchronize()
    }
    
    static func getToken() -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey(TokenHelper.TOKEN_KEY)
    }

}
