//
//  HitboxStream.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/15/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

struct HitboxStreamVideo {
    private(set) var url: NSURL!
    private(set) var bitrate: Int!
    private(set) var label: String!
    private(set) var isDefault: Bool!
    
    init?(dict: [String : AnyObject]) {
        guard let urlString = dict["url"] as? String, url = NSURL(string: urlString) else {
            return nil
        }
        guard let bitrate = dict["bitrate"] as? Int else {
            return nil
        }
        guard let label = dict["label"] as? String else {
            return nil
        }
        guard let isDefault = dict["isDefault"] as? Bool else {
            return nil
        }
        
        //check if the url is valid, for some reason the API returns shit
        guard NSURLConnection.canHandleRequest(NSURLRequest(URL: url)) else {
            return nil
        }
        
        self.url = url
        self.bitrate = bitrate
        self.label = label
        self.isDefault = isDefault
    }
}
