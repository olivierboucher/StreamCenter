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
    private(set) var thumbnails : [YoutubeThumbnailResolution : String]?
    private(set) var id : String = ""
    
    private var mImage: UIImage?
    
    init?(dict: [String : AnyObject]) {
        guard let snippet = dict["snippet"] as? [String : AnyObject] else {
            return nil
        }
        guard let id = dict["id"] as? [String : AnyObject], videoID = id["videoId"] as? String else {
            return nil
        }
        guard let title = snippet["title"] as? String else {
            return nil
        }
        guard let channelId = snippet["channelId"] as? String else {
            return nil
        }
        guard let channelName = snippet["channelTitle"] as? String else {
            return nil
        }
        guard let description = snippet["description"] as? String else {
            return nil
        }
        
        self.id = videoID
        self.title = title
        self.channelId = channelId
        self.channelName = channelName
        self.description = description
        
        guard let thumbnails = snippet["thumbnails"] as? [String : [String : String]] else {
            return
        }
        
        self.thumbnails = [YoutubeThumbnailResolution : String]()
        
        if let low = thumbnails["default"]?["url"] {
            self.thumbnails![.Low] = low
        }
        
        if let med = thumbnails["medium"]?["url"] {
            self.thumbnails![.Medium] = med
        }
        
        if let high = thumbnails["high"]?["url"] {
            self.thumbnails![.High] = high
        }
    }
    
//    var streamURL: NSURL {
//        get {
//            return NSURL(string: "http://www.youtube.com/embed/\(id)?autoplay=1")!
//        }
//    }
    
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