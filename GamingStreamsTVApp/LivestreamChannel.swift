//
//  LivestreamChannel.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/21/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

class LivestreamChannel {
    
    private(set) var title: String!
    private(set) var link: NSURL!
    private(set) var description: String!
    private(set) var category: String!
    private(set) var viewsCount: Int!
    private(set) var totalClips: Int!
    private(set) var directories = [LivestreamDirectory]()
    
    init?(dict: [String : AnyObject]) {
        
        guard let title = dict["title"] as? String else {
            return nil
        }
        guard let linkString = dict["link"] as? String, link = NSURL(string: linkString) else {
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
        
        self.title = title
        self.link = link
        self.description = description
        self.category = category
        self.viewsCount = viewsCount
        self.totalClips = totalClips
        
        if let dirDict = dict["directory"] as? [String : AnyObject] {
            if let directory = LivestreamDirectory(dict: dirDict) {
                self.directories = [directory]
            }
        } else if let dirArray = dict["directory"] as? [[String : AnyObject]] {
            for dirDict in dirArray {
                if let directory = LivestreamDirectory(dict: dirDict) {
                    self.directories.append(directory)
                }
            }
        }
        
    }
    
    var channelID: String? {
        get {
            guard let components = self.link.pathComponents else {
                return nil
            }
            let filteredComponents = components.filter({ $0 != "/" })
            guard filteredComponents.count > 0 else {
                return nil
            }
            return filteredComponents[0]
        }
    }
    
}

struct LivestreamDirectory {
    
    let id: String!
    let title: String!
    let hasClips: Bool!
    let directories: [LivestreamDirectory]?
    
    init?(dict: [String : AnyObject]) {
        guard let id = dict["@id"] as? String else {
            return nil
        }
        guard let title = dict["@title"] as? String else {
            return nil
        }
        guard let hasClips = dict["@hasClips"] as? Bool else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.hasClips = hasClips
        
        if let dirDict = dict["directory"] as? [String : AnyObject] {
            if let directory = LivestreamDirectory(dict: dirDict) {
                self.directories = [directory]
            } else {
                self.directories = nil
            }
        } else if let dirArray = dict["directory"] as? [[String : AnyObject]] {
            var dirs = [LivestreamDirectory]()
            for dirDict in dirArray {
                if let directory = LivestreamDirectory(dict: dirDict) {
                    dirs.append(directory)
                }
            }
            self.directories = dirs
        } else {
            self.directories = nil
        }
    }
    
}