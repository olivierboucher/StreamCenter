//
//  HitboxStream.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/15/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

struct HitboxStreamVideo {
    let url: NSURL!
    let bitrate: Int!
    let label: String!
    let isDefault: Bool!
    
    init?(dict: [String : AnyObject]) {
        guard let urlString = dict["url"] as? String else {
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
        
//        //check if the url is valid, for some reason the API returns shit
//        //can't use this check because it returns false for rtmp://
//        guard NSURLConnection.canHandleRequest(NSURLRequest(URL: url)) else {
//            return nil
//        }
        
//        let regex = "(http|https|rtmp)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
//        let test = NSPredicate(format: "SELF MATCHES %@", regex)
//        guard let path = url.path where test.evaluateWithObject(path) else {
//            return nil
//        }
        
        var url = NSURL(string: urlString)
        if url?.host == nil || url?.scheme == "" {
            url = NSURL(string: "http://www.hitbox.tv" + urlString)
        }
        
        guard let realURL = url where realURL.host != nil && !["", "rtmp"].contains(realURL.scheme) && url?.pathExtension == "m3u8" else {
            Logger.Error("Url is invalid: \(url?.absoluteString)")
            return nil
            
        }
        
        self.url = url
        self.bitrate = bitrate
        self.label = label
        self.isDefault = isDefault
    }
    
    
    
    /*
    * alternativeCreation(dict: [String : AnyObject]?) -> [HitboxStreamVideo]
    *
    * If the hitbox api returned a stream that is getting sent over rtmp, the parsing is going to fail in init?(dict) due to an invalid URL
    * In this method we reformat the dict a little bit and try again with a different URL
    *
    */
    static func alternativeCreation(dict: [String : AnyObject]?) -> [HitboxStreamVideo] {
        var streams = [HitboxStreamVideo]()
        
        guard let dict = dict else {
            return streams
        }
        
        guard let netConnString = dict["netConnectionUrl"] as? String else {
            return streams
        }
        
        guard let bitrates = dict["bitrates"] as? [[String : AnyObject]] where bitrates.count > 0 else {
            return streams
        }
        
        for i in 0..<bitrates.count {
            var bitrate = bitrates[i]
            if let url = bitrate["url"] as? String {
                bitrate["url"] = netConnString + "/" + url
            }
            if let stream = HitboxStreamVideo(dict: bitrate) {
                streams.append(stream)
            }
        }
        
        return streams
    }
    
}
