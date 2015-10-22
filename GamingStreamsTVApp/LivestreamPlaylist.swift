//
//  LivestreamPlaylist.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/22/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class LivestreamPlaylist {
    
    private(set) var channelTitle: String!
    private(set) var playlistTitle: String!
    private(set) var description: String!
    private(set) var category: String!
    private(set) var viewsCount: Int!
    private(set) var totalClips: Int!
    private(set) var clips = [LivestreamClip]()
    
    init?(dict: [String : AnyObject]) {
        
        guard let channelTitle = dict["title"] as? String else {
            return nil
        }
        guard let playlistTitle = dict["playlistTitle"] as? String else {
            return nil
        }
        guard let description = dict["description"] as? String else {
            return nil
        }
        guard let category = dict["category"] as? String else {
            return nil
        }
        guard let viewsCount = dict["viewsCount"] as? Int else {
            return nil
        }
        guard let totalClips = dict["totalClips"] as? Int else {
            return nil
        }
        
        self.channelTitle = channelTitle
        self.playlistTitle = playlistTitle
        self.description = description
        self.category = category
        self.viewsCount = viewsCount
        self.totalClips = totalClips
        
        if let clipArray = dict["directory"] as? [[String : AnyObject]] {
            for clipDict in clipArray {
                if let clip = LivestreamClip(dict: clipDict) {
                    self.clips.append(clip)
                }
            }
        }
        
    }

}

struct LivestreamClip {
    
    let title: String!
    let description: String!
    let viewsCount: Int!
    let url: NSURL!
    let thumbURL: NSURL?
    
    init?(dict: [String : AnyObject]) {
        
        guard let title = dict["title"] as? String else {
            return nil
        }
        guard let description = dict["description"] as? String else {
            return nil
        }
        guard let viewsCount = dict["viewsCount"] as? Int else {
            return nil
        }
        guard let content = dict["content"] as? [String : AnyObject], urlString = content["@url"] as? String else {
            return nil
        }
        guard let url = NSURL(string: urlString) else {
            return nil
        }
        
        self.title = title
        self.description = description
        self.viewsCount = viewsCount
        self.url = url
        
        guard let thumbnailDict = dict["thumbnail"] as? [String : AnyObject], thumbUrlString = thumbnailDict["@url"] as? String else {
            self.thumbURL = nil
            return
        }
        
        if let thumbURL = NSURL(string: thumbUrlString) {
            self.thumbURL = thumbURL
        } else {
            self.thumbURL = nil
        }
        
    }
    
}
