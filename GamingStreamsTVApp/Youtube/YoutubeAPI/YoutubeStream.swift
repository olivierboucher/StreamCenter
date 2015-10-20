//
//  YoutubeStream.swift
//  GamingStreamsTVApp
//
//  Created by Chayel Heinsen on 10/10/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import UIKit

class YoutubeStream : CellItem {
    private(set) var channelId: String = ""
    private(set) var channelName: String = ""
    private(set) var description: String = ""
    private(set) var title: String = ""
    private(set) var thumbnails : Dictionary<YoutubeThumbnailResolution, String>?
    private(set) var id : String = ""
    
    private var mImage: UIImage?
    
    init(id : String, title : String, channelId : String, channelName : String, description : String, thumbnails : Dictionary<YoutubeThumbnailResolution, String>?) {
        self.id = id;
        self.title = title;
        self.channelId = channelId;
        self.channelName = channelName;
        self.description = description;
        self.thumbnails = thumbnails;
    }
    
    var streamURL: NSURL {
        get {
            return NSURL(string: "http://www.youtube.com/embed/\(id)?autoplay=1")!
        }
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
    
    var bannerString: String? {
        get {
            return nil
        }
    }
    
    var image: UIImage? {
        get {
            return mImage
        }
    }
    
    func setImage(image: UIImage) {
        mImage = image
    }

}

enum YoutubeThumbnailResolution {
    case Low, Medium, High
}