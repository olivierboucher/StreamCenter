//
//  LivestreamAPI.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/21/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import Alamofire

class LivestreamAPI {
    
    static let AffiliateID = ""
    static let ApplicationKey = "6vpTDGxxeLSUJLaATL1vKvT-5z32RoFPHYmGPmctzNHHRpWXSXM6oiBbkO1KbvOxJ4fb7qFDb3q1Ob50CjwSmuUM8Li2YImqO_ycO2Te51eIkwZDtVLb6ChoP9woyBR5"
    
//    static func getChannels(resultsPerPage: Int, pageNumber: Int, completionHandler: (channels: [LivestreamChannel]?, error: ServiceError?) -> ()) {
//        let urlString = ""
//        let parameters : [String : AnyObject] = [
//            "method"            : "getChannels",
//            "affiliateId"       : LivestreamAPI.AffiliateID,
//            "applicationKey"    : LivestreamAPI.ApplicationKey,
//            "channelType"       : "LIVE",
//            "pageNumber"        : pageNumber,
//            "resultsPerPage"    : resultsPerPage,
//            "orderBy"           : "currentViewers",
//            "orderType"         : "DESC"
//        ]
//        Alamofire.request(.GET, urlString, parameters: parameters, encoding: .PropertyList(.XMLFormat_v1_0, 0)).responsePropertyList { response in
//            if response.result.isSuccess {
//                if let dictionary = response.result.value as? [String : AnyObject] {
//                    
//                }
//                completionHandler(channels: nil, error: .JSONError)
//            } else {
//                completionHandler(channels: nil, error: .URLError)
//            }
//        }
//    }
    
    static func getChannelInformation(forChannel channel: String, completionHandler: (channel: LivestreamChannel?, error: ServiceError?) -> ()) {
        let urlString = "http://x\(channel)x.api.channel.livestream.com/2.0/listplaylists.json"
        Alamofire.request(.GET, urlString).responseJSON { response in
            if response.result.isSuccess {
                if let dictionary = response.result.value as? [String : AnyObject] {
                    if let channelDict = dictionary["channel"] as? [String : AnyObject] {
                        if let channel = LivestreamChannel(dict: channelDict) {
                            completionHandler(channel: channel, error: nil)
                            return
                        }
                    }
                }
                completionHandler(channel: nil, error: .JSONError)
            } else {
                completionHandler(channel: nil, error: .URLError)
            }
        }
    }
    
    static func getClipsForPlaylist(forChannel channel: LivestreamChannel, andPlaylistID playlist: String, completionHandler: (clips: [LivestreamClip]?, error: ServiceError?) -> ()) {
        
        guard let channelID = channel.channelID else {
            completionHandler(clips: nil, error: .URLError)
            return
        }
        
        let urlString = "http://x\(channelID)x.api.channel.livestream.com/2.0/listclips.json?id=\(playlist)"
        Alamofire.request(.GET, urlString).responseJSON { response in
            if response.result.isSuccess {
                if let dictionary = response.result.value as? [String : AnyObject] {
                    if let channelDict = dictionary["channel"] as? [String : AnyObject] {
                        if let clipDicts = channelDict["item"] as? [[String : AnyObject]] {
                            var clips = [LivestreamClip]()
                            for clipDict in clipDicts {
                                if let clip = LivestreamClip(dict: clipDict) {
                                    clips.append(clip)
                                }
                            }
                            completionHandler(clips: clips, error: nil)
                            return
                        }
                    }
                }
                completionHandler(clips: nil, error: .JSONError)
            } else {
                completionHandler(clips: nil, error: .URLError)
            }
        }
    }

}
