//
//  YoutubeStream.swift
//  GamingStreamsTVApp
//
//  Created by Chayel Heinsen on 10/10/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

struct YoutubeStream : CellItem {
    private(set) var channelId: String = ""
    private(set) var channelName: String = ""
    private(set) var description: String = ""
    private(set) var title: String = ""
    private(set) var thumbnails : Dictionary<YoutubeThumbnailResolution, String>?
    private(set) var id : String = ""
    
    init(id : String, title : String, channelId : String, channelName : String, description : String, thumbnails : Dictionary<YoutubeThumbnailResolution, String>?) {
        self.id = id;
        self.title = title;
        self.channelId = channelId;
        self.channelName = channelName;
        self.description = description;
        self.thumbnails = thumbnails;
    }
    
    func streamURL() -> NSURL {
        return NSURL(string: String(format: "http://www.youtube.com/embed/%@?autoplay=1", id))!
    }
    
    var urlTemplate: String? {
        get {
            
            if let preview = thumbnails {
                return preview[.High]
            } else {
                return nil
            }
        }
    }
    
    var subtitle: String {
        get {
            return description
        }
    }

}

enum YoutubeThumbnailResolution {
    case Low, Medium, High
}