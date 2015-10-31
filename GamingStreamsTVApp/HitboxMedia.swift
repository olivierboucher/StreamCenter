//
//  HitboxMedia.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/12/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit

struct HitboxMedia: CellItem {
    
    let id : Int!
    let name : String!
    let displayName : String?
    let views : Int!
    let thumbnail : String!
    let userMediaId : String!
    let countries : [String]?
    var chatEnabled = false
    let transcoding : Int!
    
    private var mImage: UIImage?
    
    init?(dict: [String : AnyObject]) {
        
        guard let id = dict["media_id"] as? String, intId = Int(id) else {
            return nil
        }
        guard let name = dict["media_display_name"] as? String else {
            return nil
        }
        guard let thumb = dict["media_thumbnail"] as? String else {
            return nil
        }
        guard let viewers = dict["media_views"] as? String, intViews = Int(viewers) else {
            return nil
        }
        guard let channelDict = dict["channel"] as? [String : AnyObject] else {
            return nil
        }
        guard let userMediaId = channelDict["user_media_id"] as? String else {
            return nil
        }
        
        self.id = intId
        self.name = name
        self.thumbnail = thumb
        self.views = intViews
        self.userMediaId = userMediaId
        self.countries = dict["media_countries"] as? [String]
        self.displayName = dict["media_display_name"] as? String
        
        if let chat = dict["media_chat_enabled"] as? String where chat == "1" {
            self.chatEnabled = true
        }
        
        if let strTranscoding = dict["media_transcoding"] as? String, transcoding = Int(strTranscoding) {
            self.transcoding = transcoding
        }
        else {
            self.transcoding = -1
        }
    }
    
    var urlTemplate: String? {
        get {
            return "https://edge.sf.hitbox.tv" + thumbnail
        }
    }
    
    var title: String {
        get {
            return name
        }
    }
    
    var subtitle: String {
        get {
            if views > 0 {
                return "\(views) views"
            } else {
                return " "
            }
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
    
    mutating func setImage(image: UIImage) {
        mImage = image
    }

}