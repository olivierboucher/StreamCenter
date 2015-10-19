//
//  TwitchUser.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/17/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class TwitchUser {
    
    var name: String!
    var displayName: String!
    var bio: String?
    var email: String?
    var logoURL: String?
    
    init?(dict: [String : AnyObject]) {
        
        guard let name = dict["name"] as? String, displayName = dict["display_name"] as? String else {
            return nil
        }
        
        self.name = name
        self.displayName = displayName
        
        if let logo = dict["logo"] as? String {
            self.logoURL = logo
        }
        
        if let email = dict["email"] as? String {
            self.email = email
        }
        
        if let bio = dict["bio"] as? String {
            self.bio = bio
        }
        
    }

}
